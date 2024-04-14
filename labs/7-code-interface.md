# Lab 7 - Code Interface

## Relevant Documentation

- [Code Interface](https://hexdocs.pm/ash/3.0.0-rc.21/code-interfaces.html)

## Steps

Now, if we look at the places that we're interacting with our application, we're calling functions on the `Ash` module, and providing our resource. There is nothing wrong with doing this, but we want to provide an interface to our application, *even for in-code usage*.

1. To start, lets add an interface for our `:feed` action. We do this inside the block for the resource we want to call in our domain.

```elixir
resource Twitter.Tweets.Tweet do
  define :feed
end
```

2. then we can replace that in our logic to fetch tweets on mount

```elixir
|> stream(
  :tweets,
  Twitter.Tweets.feed!(load: @tweet_loads, actor: socket.assigns[:current_user])
)
```

3. Then, we can add an interface for getting an individual tweet. We'll call this `:get_tweet`. Since the action name is not the same as the function, we'll need to add the `action` option. And we want to filter by `id`, and expect a single result, so we'll use `get_by: [:id]`

```elixir
define :get_tweet, action: :read, get_by: [:id]
```

4. Now lets use that in our `:edit` handler

```elixir
|> assign(:tweet, Twitter.Tweets.get_tweet!(id, load: @tweet_loads, actor: socket.assigns.current_user))
```

5. Lastly, we'll add an interface for removing tweets. Lets call it `delete_tweet`. This will use the `:destroy` action.

6. And then we can use that in our `:delete` handler.

7. We can also clean up and simplify our `like/unlike` calls. We'll start with `like`:

```elixir
resource Twitter.Tweets.Like do
  define :like, args: [:tweet_id]
end
```

8. Now, we can replace our code for liking with this simple snippet:

```elixir
Twitter.Tweets.like!(id)
```

9. Now lets do the same with unlike. By default, update and destroy interfaces accept the record or a reference to a record as the first argument. We'll need to use the `require_reference?` to skip requiring providing that record. Without this record, the code interface will use a bulk destroy under the hood.

```elixir
resource Twitter.Tweets.Like do
  define :like, args: [:tweet_id]
  define :unlike, args: [:tweet_id], require_reference?: false
end
```

10. See if you can work out replacing the `unlike` code with our new interface!

## Try on your own

- In `iex` read the generated docs for these functions. `h Twitter.Tweets.like`
- Add a `:get_user_by_email` interface
- Add a `:popular_tweets` interface, that shows the top 10 most popular tweets.
