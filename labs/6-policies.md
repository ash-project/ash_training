# Lab 6 - Policies

- [Actors & Authorization](https://hexdocs.pm/ash/3.0.0-rc.21/actors-and-authorization.html)
- [Policies](https://hexdocs.pm/ash/3.0.0-rc.21/policies.html)

## Existing Setup

- User has policy for allowing `AshAuthentication` to do whatever it wants
- User has policy for allowing anyone to read any user

## Steps

1. Add the `Ash.Policy.Authorizer` authorizer to `Tweet`.

2. Add a policy for `action_type(:read)`

```elixir
policies do
  policy action_type(:read) do
    authorize_if always()
  end
end
```

2. We can read tweets now, but can't create. Lets add a tweet allowing any user to create.


```elixir
policy action(:create) do
  authorize_if always()
end
```

3. We can read and create tweets now, but what happens if we update/destroy them? Add policies allowing the right user to update/destory.

```elixir
policy action([:update, :destroy]) do
  authorize_if expr(user_id == ^actor(:id))
end
```

4. Alright, so now we've got appropriate policies set up for tweets, but in the UI it still looks like we can delete or edit other user's tweets. Lets add some checks to the UI to make sure we only show the edit/delete buttons for the right user.

```elixir
<%= if Ash.can?({tweet, :update}, @current_user) do %>

<% end %>


<%= if Ash.can?({tweet, :destroy}, @current_user) do %>

<% end %>
```

5. Now lets add some policies to the user resource. We start off with some builtin policies recommended by AshAuthentication, as well as a blanket policy allowing anyone to read all users. This isn't ideal, so lets add a policy to only allow users to read themselves.

```elixir
policy action_type(:read) do
  authorize_if expr(id == ^actor(:id))
end
```

6. You'll see that if you load tweets, you can no longer see the email of the user who tweeted, unless it is the current user! This is a great example of how Ash helps you apply policies *everywhere* in your app, even places that are commonly overlooked.

7. This is of course, not the UX we want, so lets add the `authorize?: false` flag to the `user_email` agggregate on tweet.

```elixir
policy action_type(:read) do
  authorize_if expr(id == ^actor(:id))
end
```

## Try on your own

- Add a flag on tweets called `:private`. Add a checkbox to the UI for it. Only show private tweets to users who are the author of the tweet.

```elixir
<.input label="Private" type="checkbox" name="tweet[private]" value={@tweet && @tweet.private} />
```

- Add a flag on users called `:disabled`, and a policy on tweets that prevents them from reading tweets. See what happens when you log in as one of these users (you'll need to set that attribute by calling an action in `iex`)

- Add a flag on users called `:admin`, and a [bypass](https://hexdocs.pm/ash/policies.html#bypass-policies) on tweets that allows users to read any tweet if they are an admin.
