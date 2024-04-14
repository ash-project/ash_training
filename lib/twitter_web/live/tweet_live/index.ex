defmodule TwitterWeb.TweetLive.Index do
  use TwitterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Tweets
      <:actions>
        <.link patch={~p"/tweets/new"}>
          <.button>New Tweet</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="tweets"
      rows={@streams.tweets}
      row_click={fn {_id, tweet} -> JS.navigate(~p"/tweets/#{tweet}") end}
    >
      <:col :let={{_id, tweet}} label="Id">
        <%= tweet.id %>
      </:col>

      <:action :let={{_id, tweet}}>
        <div class="sr-only">
          <.link navigate={~p"/tweets/#{tweet}"}>Show</.link>
        </div>

        <.link patch={~p"/tweets/#{tweet}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, tweet}}>
        <.link
          phx-click={JS.push("delete", value: %{id: tweet.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="tweet-modal" show on_cancel={JS.patch(~p"/")}>
      <.live_component
        module={TwitterWeb.TweetLive.FormComponent}
        id={(@tweet && @tweet.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        tweet={@tweet}
        patch={~p"/"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :tweets,
       Ash.read!(Twitter.Tweets.Tweet, actor: socket.assigns.current_user)
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tweet")
    |> assign(:tweet, Ash.get!(Twitter.Tweets.Tweet, id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tweet")
    |> assign(:tweet, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tweets")
    |> assign(:tweet, nil)
  end

  @impl true
  def handle_info({TwitterWeb.TweetLive.FormComponent, {:saved, tweet}}, socket) do
    {:noreply, stream_insert(socket, :tweets, tweet)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Twitter.Tweets.Tweet
    |> Ash.get!(id)
    |> Ash.Changeset.for_destroy(:destroy)
    |> Ash.destroy!()

    {:noreply, stream_delete(socket, :tweets, %{id: id})}
  end

  # defp refetch_tweet(socket, id) do
  #   stream_insert(
  #     socket,
  #     :tweets,
  #     Twitter.Tweets.get_tweet!(id, actor: socket.assigns.current_user, load: @tweet_loads)
  #   )
  # end
end
