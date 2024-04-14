# Lab 4 - Calculations

## Relevant Documentation

- [Calculations](https://hexdocs.pm/ash/3.0.0-rc.21/calculations.html)
- [Expressions](https://hexdocs.pm/ash/3.0.0-rc.21/expressions.html)

## Steps

1. We want to display two things about a tweet in the UI. How many characters it has, and if the current user has liked it. (We will get into "how many likes does it have" in the next section on aggregates).

2. Lets add a calculation to the tweet resource to calculate the length of the text.

```elixir
calculate :text_length, :integer, expr(string_length(text))
```

3. Now we can add this to `@tweet_loads`, and show it as its own column in the UI

```elixir
<:col :let={{_id, tweet}} label="Length">
  <%= tweet.text_length %>
</:col>
```

4. Now we want to show if the current user has liked the tweet.

```elixir
calculate :liked_by_me, :boolean, expr(exists(likes, user_id == ^actor(:id))
```

5. Now, lets replace our like and unlike buttons with a heart icon. Add `:liked_by_me` to `@tweet_loads`, and use that to conditionally make the hart icon red. We'll also change the column label from "Actions" to "Likes". We'll explore that reasoning a bit more in the next section on  aggregates.

```elixir
<:col :let={{_id, tweet}} label="Likes">
  <%= if tweet.liked_by_me do %>
    <button phx-click="unlike" phx-value-id={tweet.id}>
      <.icon name="hero-heart-solid" class="text-red-600" />
    </button>
  <% else %>
    <button phx-click="like" phx-value-id={tweet.id}>
      <.icon name="hero-heart" />
    </button>
  <% end %>
</:col>
```

## Try on your own

- Use a module calculation to calculate the text length
- Use a module calculation to calculate likes per character
- Use an expression calculation to calculate likes per character
