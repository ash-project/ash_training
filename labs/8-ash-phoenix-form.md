# Lab 8 - `AshPhoenix.Form`

## Relevant Documentation

- [AshPhoenix.Form](https://hexdocs.pm/ash_phoenix/2.0.0-rc.4/AshPhoenix.Form.html)

## Steps

1.  We can simplify a lot of our form code using `AshPhoenix.Form`. We get error handling, automatic setting of values, and more.

2. To start, we will add an `assign_form/1` helper, and call it from our `update/2` handler

```elixir
defp assign_form(%{assigns: %{tweet: tweet}} = socket) do
  form =
    if tweet do
      AshPhoenix.Form.for_update(tweet, :update,
        as: "tweet"
      )
    else
      AshPhoenix.Form.for_create(Twitter.Tweets.Tweet, :create,
        as: "tweet",
        transform_params: fn params, _ ->
          Map.put(params, "user_id", socket.assigns.current_user.id)
        end
      )
    end

  assign(socket, form: to_form(form))
end
```

```elixir
@impl true
def update(assigns, socket) do
  {:ok,
   socket
   |> assign(assigns)
   |> assign_form()}
end
```

3. Then, we can add in a `"validate"` step, to show errors on each keystroke

```elixir
@impl true
def handle_event("validate", %{"tweet" => tweet_params}, socket) do
  {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, tweet_params))}
end
```

To do this, we'll change our `"save"` event handler to this:

```elixir
case AshPhoenix.Form.submit(socket.assigns.form, params: tweet_params) do
  {:ok, tweet} ->
    notify_parent({:saved, tweet})

    socket =
      socket
      |> put_flash(:info, "Tweet #{socket.assigns.form.source.type}d successfully")
      |> push_patch(to: socket.assigns.patch)

    {:noreply, socket}

  {:error, form} ->
    {:noreply, assign(socket, form: form)}
end
```


4. Then, we can modify our `<.simple_form >` to use this form.

```elixir
<.simple_form
  for={@form}
  id="tweet-form"
  phx-target={@myself}
  phx-change="validate"
  phx-submit="save"
>
  <.input label="Text" type="textarea" field={@form[:text]} />
  <:actions>
    <.button phx-disable-with="Saving...">Save Tweet</.button>
  </:actions>
</.simple_form>
```

5. Now, if you go and modify your `:text` attribute to have a constraint that would cause an error, for example:

```elixir
attribute :text, :string do
  constraints max_length: 5
end
```

You will see the validation errors automatically appear as soon as you meet the error conditions.
