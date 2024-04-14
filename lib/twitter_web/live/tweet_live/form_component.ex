defmodule TwitterWeb.TweetLive.FormComponent do
  use TwitterWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage tweet records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={%{}}
        as={:tweet}
        id="tweet-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <:actions>
          <.button phx-disable-with="Saving...">Save Tweet</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def handle_event("save", params, socket) do
    result =
      if socket.assigns.tweet do
        # we're updating a tweet
        {:error, "Not implemented"}
      else
        Twitter.Tweets.Tweet
        |> Ash.Changeset.for_create(:create, params["tweet"] || %{}, actor: socket.assigns.current_user)
        |> Ash.create()
      end

    case result do
      {:ok, tweet} ->
        notify_parent({:saved, tweet})

        socket =
          socket
          |> put_flash(:info, "Success!")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, _error} ->
        {:noreply, socket}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
