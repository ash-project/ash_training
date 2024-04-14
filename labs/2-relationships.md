# Lab 2 - Relationships

## Relevant Documentation

- [Relationships](https://hexdocs.pm/ash/3.0.0-rc.21/relationships.html)

## Steps

1. We want to associate tweets to a user, so we'll add a `belongs_to :user` relationship to the `Tweet` resource:

```elixir
belongs_to :user, Twitter.Accounts.User do
  allow_nil? false
end
```

Then we can add `:user_id` to the `accept` list for the `:create` action, and set the `:user_id` attribute to the current user's id in when creating a tweet. We'll use `Map.put` to put the user_id in the tweet's params (for now). Put this at the top of the `"save"` handler.

```elixir
params = put_in(params, ["tweet", "user_id"], socket.assigns.current_user.id)
```

2. Now we can show the `email` of the user who created the tweet in the tweet list. At the top of `TwitterWeb.TweetLive.Index`, add a module attribute called `@tweet_loads` containing the path to the data we want to load.

```elixir
@tweet_loads [user: [:email]
```

Then, alter our calls to `Ash.read!` and `Ash.get!` to include the `load` option. `load: @tweet_loads`.

Then we'll change our `:saved` handler to load this data as well.

```elixir
@impl true
def handle_info({TwitterWeb.TweetLive.FormComponent, {:saved, tweet}}, socket) do
  tweet = Ash.load!(tweet, @tweet_loads, actor: socket.assigns.current_user)
  {:noreply, stream_insert(socket, :tweets, tweet)}
end
```

and show the email in the table:

```elixir
<:col :let={{_id, tweet}} label="Author">
  <%= tweet.user.email %>
</:col>
```

3. To track when a tweet has been liked, we'll add a `Twitter.Tweets.Like` resource. We'll store it in a table called `"likes"`, and it will have just a primary key. Lets add a default `:read` action as well, with `defaults [:read]`. Don't forget to add it to the `Tweets` domain!

4. We'll add two relationships to the `Like` resource. First, we'll add a `belongs_to :tweet` relationship. This is the tweet that you are liking. We want to set `allow_nil?` to `false` here as well.

```elixir
relationships do
  belongs_to :tweet, Twitter.Tweets.Tweet do
    allow_nil? false
  end
end
```

5. Then, do the same with the `:user` relationship, except the destination of the relationship will be `Twitter.Accounts.User`.

6. Finally, we'll add the relationship to the `Tweet` resource, using `has_many`. The `allow_nil?` option does not apply in this case, because that option is not supported for `has_many` (and its okay if a tweet has no likes anyway).

7. Now, we'll add a (temporary) `:create` action to `Like` to allow us to play with the relationships.

```elixir
create :create do
  accept [:tweet_id, :user_id]
end
```

Now in IEX we can add a like for a tweet, like so:

```elixir
Twitter.Tweets.Like
|> Ash.Changeset.for_create(:create, %{tweet_id: tweet_id, user_id: user_id})
|> Ash.create!()
```

And then we can load the related likes for a tweet!

```elixir
Twitter.Tweets.Tweet
|> Ash.Query.load(:likes)
|> Ash.read!()
```

## Try on your own

- Show the `user.id` in the tweet list in the same way we're showing the `user.email`.

- In `iex`, list all of the users, and load their tweets.

- Add a `dislikes` relationship, and a resource for tracking `dislikes`.
