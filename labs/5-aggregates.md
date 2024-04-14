# Lab 5 - Aggregates

## Relevant Documentation

- [Aggregates](https://hexdocs.pm/ash/3.0.0-rc.21/aggregates.html)

## Steps

1. We want to see how many likes a tweet has. We can do this by adding an aggregate to the tweet resource. In larger applications you may need to cache this number, but for demonstration purposes we will calculate it on the fly each time.

```elixir
count :like_count, :likes do
  public? true
end
```

2. Now we can add `:like_count` to our `@tweet_loads` in the view, and then display it next to the heart icon.

```elixir
<%= tweet.like_count %>
```

3. Currently, for showing the user's email, we load the user for each tweet. We can use the `first` aggregate to not only is this more efficient, but also make the next section on policies simpler.

```elixir
first :user_email, :user, :email do
  public? true
end
```

4. Then, remove the `user: [:email]` from `@tweet_loads`, and add `:user_email`, and update our view to show it:

```elixir
<:col :let={{_id, tweet}} label="Author">
  <%= tweet.user_email %>
</:col>
```

## Try on your own

- Add a `first` aggregate to get the "email of the user who most recently liked the tweet"
- Add a `list` aggregate to get the "emails of all users who liked the tweet"
- Add a `max` aggregate to users to get the "amount of likes on their most liked tweet"
