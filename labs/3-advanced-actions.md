# Lab 3 - Advanced Actions

## Relevant Documentation

- [Attributes](https://hexdocs.pm/ash/3.0.0-rc.21/attributes.html)
- [Create Actions](https://hexdocs.pm/ash/3.0.0-rc.21/create-actions.html)
- [Update Actions](https://hexdocs.pm/ash/3.0.0-rc.21/update-actions.html)
- [Read Actions](https://hexdocs.pm/ash/3.0.0-rc.21/read-actions.html)
- [Destroy Actions](https://hexdocs.pm/ash/3.0.0-rc.21/destroy-actions.html)
- [Builtin Changes](https://hexdocs.pm/ash/3.0.0-rc.21/Ash.Resource.Change.Builtins.html)
- [Builtin Validations](https://hexdocs.pm/ash/3.0.0-rc.21/Ash.Resource.Validation.Builtins.html)

## Steps

1. Lets add `:like` and `:unlike` actions, to allow creating and destroying likes for tweets.

2. We'll start with `:like`, which accepts the `:tweet_id`. We can now remove the `:create` action that we added.

```elixir
create :like do
  accept [:tweet_id]
end
```

If you try to run this action right now, you'll see that this doesn't work. This is because there is a relationship to `:user` that is required. We want to associate the current actor with the like. We *could* accept `:user_id` as input, but what we actually want is for whoever is doing the action to be associated, not just any supplied user. For that, we will use a builtin `change` called `relate_actor`.

```elixir
create :like do
  accept [:tweet_id]

  change relate_actor(:user)
end
```

3. Now, lets add a "like" button and event in our liveview

```elixir
<:col :let={{_id, tweet}} label="Actions">
  <button phx-click="like" phx-value-id={tweet.id}>
    <.icon name="hero-arrow-up" />
  </button>
</:col>
```

4. Then we'll add an event handler for it. We'll also need to uncomment our `refetch_tweet` helper.

```elixir
def handle_event("like", %{"id" => id}, socket) do
  Twitter.Tweets.Like
  |> Ash.Changeset.for_create(:like, %{tweet_id: tweet_id})
  |> Ash.create!()

  {:noreply, refetch_tweet(socket, id)}
end
```

5. Now, if we push our `like` button, we can see the logs in the background showing the like being created. If we push it *again*, we create *another* like! This isn't ideal. To address this, we'll add an `identity`, expressing that a user can only like a tweet once.

```elixir
# in iex, delete all likes
Twitter.Tweets.Like
|> Ash.bulk_destroy!()
```

Then we'll add the identity to the `Like` resource, and run `mix ash.codegen make_likes_unique_on_user_tweet` and `mix ash.migrate`.

```elixir
identities do
  identity :unique_user_tweet, [:user_id, :tweet_id]
end
```

6. Now, if we create a second like, we see an error! We could handle this in one of two ways. First, we could use `Tweet.like` and check the response for a specific error and ignore the error if it matches our issue. However, our preferred fix here is to perform an "upsert". This means we create the record if it doesn't exist, or update it if it is.

```elixir
create :like do
  accept [:tweet_id]
  change relate_actor(:user)
  upsert? true
  upsert_identity :unique_user_tweet
end
```

This will create a record, unless there is a record matching the `:user_id` and `:tweet_id` combination, in which case it will update it instead. For this, however, there are no changes that aren't part of the upsert identity

7. Next up, we'll create the `:unlike` action. Destroying is similar to the `:like` action, in that we want to allow it to be repeatable without a consequence. To accomplish this, we will use a "filter" on our destroy action. This will make the destroy action apply only to the given tweet id, and the current user.

```elixir
destroy :unlike do
  argument :tweet_id, :uuid, allow_nil?: false
  change filter(expr(tweet_id) == ^arg(:tweet_id) and user_id == ^actor(:id))
end
```

To call this action, we don't want to use `Ash.destroy`, because that expects a record or a changeset to be provided. Instead, we would use `Ash.bulk_destroy!`. For example:

```elixir
Ash.bulk_destroy!(Like, :unlike, %{}, actor: current_user)
```

8. Now, we can add an "unlike" button next to our "like" button, and add an event handler for it. We've left this out as an exercise.

9. Now we can see that removing a tweet that has likes will raise an error. This is because we have a foreign key constraint on the `likes` table. To address this, we'll configure the foreign key constraint in the underlying database to remove any likes if the associated tweet is removed, and then run `mix ash.codegen delete_likes_when_tweets_are_deleted`.

```elixir
postgres do
  ...
  references do
    reference :tweet, on_delete: :delete
  end
end
```

10. We want to make sure that a tweet contains valid data. For that, we'll use a `validation`. We'll add a validation that ensures that the tweet's text is not longer than 255 characters.

```elixir
create :create do
  validate string_length(:text, max: 255)
end
```

Then do the same for the `update` action.

11. Now, lets do some customization of the action we use to read our tweets. We'll add a `:feed` action, and we'll modify this action to show tweets in reverse chronological order. We'll use the `prepare` statement to do that.

```elixir
read :feed do
  prepare build(sort: [inserted_at: :desc])
end
```

Then, we can use that in our view:

```elixir
socket
|> stream(
  :tweets,
  Ash.read!(Twitter.Tweets.Tweet, actor: socket.assigns.current_user, action: :feed)
)
```

## Try on your own

- Sort the feed in the opposite direction
- Sort the feed by text
- Customize length validations on the tweet
- Check the builtin validations, and try some out in your actions
