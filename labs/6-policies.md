# Lab 6 - Policies

- [Actors & Authorization](https://hexdocs.pm/ash/actors-and-authorization.html)
- [Policies](https://hexdocs.pm/ash/policies.html)

## Existing Setup

- User has policy for allowing `AshAuthentication` to do whatever it wants
- User has policy for allowing anyone to read any user

## Steps

1. Add the `Ash.Policy.Authorizer` authorizer to `Tweet`.

```elixir
mix ash.extend Twitter.Tweets.Tweet Ash.Policy.Authorizer
```

2. Add a policy for `action_type(:read)` on tweets.

```elixir
policies do
  policy action_type(:read) do
    authorize_if always()
  end
end
```

2. Now we can read tweets, but can't create or update them. Feel free to try it out.
   Let's add a policy allowing any user to create a tweet.

```elixir
policy action(:create) do
  authorize_if always()
end
```

3. We can read and create tweets now, but what happens if we update/destroy them?
   Try it out and see. (check the logs)

Add policies allowing the author of the tweet to update/destroy.

```elixir
policy action([:update, :destroy]) do
  authorize_if expr(user_id == ^actor(:id))
end
```

4. Now we've got appropriate policies set up for tweets, but the UI still looks like we can delete or edit other user's tweets.

To test this, open an incognito window, create another user, and try to edit/delete an existing tweet.

Let's add some checks to the UI to make sure we only show the edit/delete buttons for the right user.

Wrap our edit/delete buttons in an `if` block that checks if the current user can perform the action.

```elixir
<%= if Ash.can?({tweet, :update}, @current_user) do %>

<% end %>


<%= if Ash.can?({tweet, :destroy}, @current_user) do %>

<% end %>
```

5. Now let's add some policies to the user resource. We start off with some builtin policies
   recommended by AshAuthentication, as well as a blanket policy allowing anyone to read all users.
   This isn't ideal, so let's add a policy to only allow users to read themselves.

```elixir
policy action_type(:read) do
  authorize_if expr(id == ^actor(:id))
end
```

6. You'll see that if you load the tweets page, you can no longer see the email of the user who tweeted, unless it is yourself!

This is a great example of how Ash helps you apply policies _everywhere_ in your app, even places that are commonly overlooked.

7. However, this is not the UX we want, because we still want to be able to see the email of the author of a tweet.
   So let's add the `authorize? false` option to the `user_email` aggregate on tweet.

```elixir
first :user_email, :user, :email do
  authorize? false
end
```

## Try on your own

- Generate policy flow charts with `mix ash.generate_policy_charts --all`. You can add the `--format png` option, but that requires `npm install -g @mermaid-js/mermaid-cli`, which people tend to have issues with due to node versions. To view the charts otherwise, paste the mermaid code into the [Mermaid Live Editor](https://mermaid.live/edit)

- Add an attribute on tweets called `:private`. Add a checkbox to the UI for it. Only show private tweets to users who are the author of the tweet.

```elixir
<.input label="Private" type="checkbox" name="tweet[private]" value={@tweet && @tweet.private} />
```

- Add a flag on users called `:disabled`, and a policy on tweets that prevents them from reading tweets. See what happens when you log in as one of these users (you'll need to set that attribute by calling an action in `iex`)

- Add a flag on users called `:admin`, and a [bypass](https://hexdocs.pm/ash/policies.html#bypass-policies) on tweets that allows users to read any tweet if they are an admin.
