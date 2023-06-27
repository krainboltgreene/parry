defmodule CoreWeb.RoomLive do
  @moduledoc false
  use CoreWeb, :live_view
  import Ecto.Query

  defp list_records(_assigns, _params) do
    from(
      Core.Chat.Room,
      preload: [:creator]
    )
    |> Core.Repo.all()
  end

  defp list_messages(record) do
    from(
      Core.Chat.Message,
      where: [
        external_chatroom_id: ^record.external_chatroom_id,
      ],
      order_by: [desc: :written_at]
    )
    |> Core.Repo.all()
  end

  defp count_records(_assigns) do
    Core.Repo.aggregate(Core.Chat.Room, :count, :id)
  end

  defp get_record(id) when is_binary(id) do
    from(
      Core.Chat.Room,
      where: [
        id: ^id
      ],
      preload: [:creator, :messages],
      limit: 1
    )
    |> Core.Repo.one()
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :list, params) do
    socket
    |> assign(:page_title, "Rooms")
    |> assign(:records, list_records(socket.assigns, params))
    |> assign(:record_count, count_records(socket.assigns))
  end

  defp as(socket, :show, %{"id" => id}) when is_binary(id) do
    get_record(id)
    |> case do
      nil ->
        socket
      record ->
        if connected?(socket) do
          CoreWeb.Endpoint.subscribe("chatroom-#{record.external_chatroom_id}")
        end
        socket
        |> assign(:record, record)
        |> stream(:messages, list_messages(record))
        |> assign(:page_title, "Room / #{record.creator.name}")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "insert", payload: id}, socket) do
    from(
      Core.Chat.Message,
      where: [
        id: ^id
      ],
      limit: 1
    )
    |> Core.Repo.one()
    |> case do
      nil ->
        socket
      record ->
        socket
        |> stream_insert(:messages, record, at: 0)
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h2 class="not-prose">Rooms</h2>
    <ul>
      <%= for record <- @records do %>
        <li>
          <.link href={~p"/rooms/#{record.id}"}>
            <%= record.creator.name %>'s Chatroom
          </.link>
        </li>
      <% end %>
    </ul>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h2>Room / <%= @record.creator.name %></h2>
    <ul id="messages" phx-update="stream">
      <li :for={{dom_id, message} <- @streams.messages} id={dom_id}>
        <%= message.content %>
      </li>
    </ul>
    """
  end
end
