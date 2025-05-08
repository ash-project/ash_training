# Lab 3 - Advanced Actions

## Relevant Documentation

- [Attributes](https://hexdocs.pm/ash/attributes.html)
- [Create Actions](https://hexdocs.pm/ash/create-actions.html)
- [Update Actions](https://hexdocs.pm/ash/update-actions.html)
- [Read Actions](https://hexdocs.pm/ash/read-actions.html)
- [Destroy Actions](https://hexdocs.pm/ash/destroy-actions.html)
- [Builtin Changes](https://hexdocs.pm/ash/Ash.Resource.Change.Builtins.html)
- [Builtin Validations](https://hexdocs.pm/ash/Ash.Resource.Validation.Builtins.html)

## Steps

Let's add `:like` and `:unlike` actions, to allow creating and destroying likes for tweets.
We will add these actions to the `Twitter.Tweets.Like` resource (not `Twitter.Tweets.Tweet`!)

1. We'll start with `:like`, which accepts the `:tweet_id`.
   If you added a temporary `:create` action in the previous lab, remove it now.

```elixir
create :like do
  accept [:tweet_id]
end
```

If you try to run this action in iex right now, you'll see that this doesn't work.
This is because there is a relationship to `:user` that is required.

We want to associate the current actor with the like.
We _could_ accept `:user_id` as input, but what we actually want is for whoever is doing the
action to be associated, not just any supplied user.

For that, we will use a builtin `change` called `relate_actor`.

```elixir
create :like do
  accept [:tweet_id]

  change relate_actor(:user)
end
```

2. Now, let's add a "like" button in `index.ex`. Add the following code above the other `<:action` tags.

```elixir
<:action :let={{_id, tweet}}>
  <button phx-click="like" phx-value-id={tweet.id}>
    <.icon name="hero-arrow-up" />
  </button>
</:action>
```

3. Then we'll add an event handler for it. Add this code under the other `handle_event` definition,
   and uncomment the `refetch_tweet` helper at the bottom of the file.

```elixir
def handle_event("like", %{"id" => tweet_id}, socket) do
  Twitter.Tweets.Like
  |> Ash.Changeset.for_create(:like, %{tweet_id: tweet_id}, actor: socket.assigns.current_user)
  |> Ash.create!()

  {:noreply, refetch_tweet(socket, tweet_id)}
end
```

4. Now, if we press our `like` button in the UI, we can see the like being inserted in the console logs.

If we push it _again_, we create _another_ like!

This isn't ideal, as we want to ensure that each user can only like a given tweet one time.
To address this, we'll add an `identity`, expressing that a user can only like a tweet once.

```elixir
identities do
  identity :unique_user_tweet, [:user_id, :tweet_id]
end
```

5. Now lets run our codegen tasks! You will notice that the migration will result in an error if you have any
   duplicate likes in your database. Run `mix ash.reset` in this case.

6. Now, if we create a second like, we see an error instead of allowing duplicates!

We can handle this in one of two ways.

First, we could use `Ash.create()`, which returns errors instead of `Ash.create!()` which
raises them, check the response for a specific error and ignore the error if it matches our issue.

However, our preferred approach here is to perform an "upsert".
This means we create the record if it doesn't exist, or update it if it is.

Modify your `like` action to be an upsert

```elixir
create :like do
  accept [:tweet_id]
  change relate_actor(:user)
  upsert? true
  upsert_identity :unique_user_tweet
end
```

This will create a record, unless there is a record matching the `:user_id` and `:tweet_id`
combination, in which case it will update it instead.

In this case, however, no updates will be made, as there are no changes that aren't part of the
upsert identity.

7. Next up, we'll create the `:unlike` action. Destroying is similar to the `:like`
   action, in that we want to allow it to be repeatable without a consequence.

We will leverage an `argument` for this, because `destroy` don't "accept" changes
because we're destroying the record, not updating fields.

To accomplish this, we will use the `filter/1` change on our destroy action.
This will make the destroy action apply only to the given `tweet_id`, and the current user.

```elixir
destroy :unlike do
  argument :tweet_id, :uuid, allow_nil?: false

  change filter(
    expr(tweet_id == ^arg(:tweet_id) and user_id == ^actor(:id))
  )
end
```

To call this action, we don't want to use `Ash.destroy`, because that expects a record or a changeset to be
provided. i.e `Ash.destroy(like)`. In this case, we want to destroy the like that matches some
criteria, not a specific like. For that, even though we are destroying only a single thing,
we would use `Ash.bulk_destroy!`. For example:

```elixir
Ash.bulk_destroy!(
  Twitter.Tweets.Like,
  :unlike,
  %{tweet_id: tweet_id},
  actor: socket.assigns.current_user
)
```

8. Now, try it on your own! Lets add an "unlike" button next to our "like" button, and add a `handle_event`
   function for it. Add a button, just like the `"like"` button in the same `<:action` block, but for unliking.
   Make the arrow on the button point down.

9. Then, add an event handler, just like our `"like"` event handler. Use `Ash.bulk_destroy!`, like in the example above
   to delete the relevant like. Check the logs to confirm that you see a `DELETE` statement in postgres.

10. Now, if you try to remove a tweet that has any likes, an error will be raised. This is because we have
    a foreign key constraint on the `likes` table.

```elixir
postgres do
  # add this `references` block inside the `postgres` block on `Twitter.Tweets.Like`
  references do
    reference :tweet, on_delete: :delete
  end
end
```

11. Don't forget to run your codegen tasks!

12. We can also give this same `relate_actor/1` treatment for our `:create` action on `Twitter.Tweets.Tweet`.
    Remove `:user_id` from the `accept` list, and add the `change relate_actor(:user)` to the resource.

Then you can remove the following code from the `"save"` handler in `form_component.ex`.

```elixir
params = put_in(params, ["tweet", "user_id"], socket.assigns.current_user.id)
```

13. Now we want to make sure that the tweet's text is not too long.

For that, we'll use a `validation` on `Twitter.Tweets.Tweet` that ensures that the tweet's text is
not longer than 255 characters.

```elixir
  validate string_length(:text, max: 255)
```

Add this to the `:create` and `:update` action. Then, try to create a long tweet.
You'll get an error. It won't be handled gracefully, but we'll get to that later with `AshPhoenix.Form`.

14. Now, lets do some customization of the action we use to read our tweets.
    We'll add a `:feed` action, and we'll modify this action to show tweets in reverse chronological order.
    For that, we can use a `prepare` statement.

```elixir
read :feed do
  prepare build(sort: [inserted_at: :desc])
end
```

15. Now we can use that in the `mount/3` function in `index.ex`, by changing the `action: :read` option to `action: :feed` when we call `Ash.read!`.

## Try on your own

- Sort the feed in the opposite direction
- Sort the feed by text
- Customize length validations on the tweet
- Check the builtin validations, and try some out in your actions
