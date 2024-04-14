# Lab 1 - Basic Actions and Attributes

## Relevant Documentation

- [Attributes](https://hexdocs.pm/ash/3.0.0-rc.21/attributes.html)
- [Create Actions](https://hexdocs.pm/ash/3.0.0-rc.21/create-actions.html)
- [Update Actions](https://hexdocs.pm/ash/3.0.0-rc.21/update-actions.html)
- [Read Actions](https://hexdocs.pm/ash/3.0.0-rc.21/read-actions.html)
- [Destroy Actions](https://hexdocs.pm/ash/3.0.0-rc.21/destroy-actions.html)

## Existing setup

- A shell of a UI for tweets. This is very similar to what you get by running `mix ash_phoenix.gen.live`, but simplified for this training. We will go over this before the lab.

## Steps

1. Lets start by adding an empty `:create` action to `Twitter.Tweets.Tweet`.

```elixir
actions do
  ...
  create :create do
  end
end
```

2. Now, we're going to handle the creation in the UI. Add this to your `form_component.ex`, in place of the `"we're creating a tweet"` section that currently returns an error.

```elixir
Twitter.Tweets.Tweet
|> Ash.Changeset.for_create(:create, params["tweet"] || %{}, actor: socket.assigns.current_user)
|> Ash.create()
```

Notice how this extracts params from the input. Right now we aren't using any params but this sets us up for the next step. Additionally, this passes the current user in to the changeset. Don't worry about this for now.

Now you can create a new empty tweet!

3. Next, lets add a `:text` attribute that is a `:string`, so that we can see what user's are tweeting.

4. This updates our application, but not the underlying database. To do that, we have to genreate and run migrations. run `mix ash.codegen add_text_to_tweet` to generate the required migrations, and then `mix ash.migrate` to apply them.

5. We can add an input for this in our form. We're doing this a bit "low-level" for now, but we'll discuss how this works using `AshPhoenix.Form` later on down the road. Add this inside of the form template.

```elixir
<.input label="Text" type="textarea" name="tweet[text]" value={@tweet && @tweet.text} />
```

Now you can create a tweet with some text!

6. To show this in our UI, we'll add a column for it.

```elixir
<:col :let={{_id, tweet}} label="Text">
  <%= tweet.text %>
</:col>
```

7. And then we can add an `:update` action that accepts the `:text` as well, and add a handler for it in our form component. Notice how the `create` code passes in the resource `Twitter.Tweets.Tweet`. For update actions, this works a big differently. See the update docs for more. With this, our add tweet and update tweet forms should now work.

8. Finally, we can add a `:destroy` action. This is a simple action that needs no options or configuration. Once that is done, you'll be able to destroy a tweet.

## Try on your own

- Add created_at and updated_at timestamps to the resource
- Add another text attribute, like `:label` or `:category`, and allow it to be added in the form
- Set a default value for the `:text` attribute
- Require that the `:text` attribute is not `nil`
