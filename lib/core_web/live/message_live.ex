defmodule CoreWeb.MessageLive do
  @moduledoc false
  use CoreWeb, :live_view
  import Ecto.Query

  defp list_records(_assigns, _params) do
    from(
      messages in Core.Chat.Message,
      join: rooms in assoc(messages, :room),
      join: creators in assoc(rooms, :creator),
      select: %{
        id: messages.id,
        creator_name: creators.name,
        written_at: messages.written_at,
        content: messages.content,
        tags: messages.tags
      },
      order_by: [desc: :written_at]
    )
    |> Core.Repo.all()
  end

  defp count_records(_assigns) do
    Core.Chat.count_messages()
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      CoreWeb.Endpoint.subscribe("messages")
    end
    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :list, params) do
    socket
    |> assign(:page_title, "Messages")
    |> stream(:records, list_records(socket.assigns, params))
    |> assign(:record_count, count_records(socket.assigns))
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "message:insert", payload: id}, socket) do
    Core.Chat.get_message(id)
    |> Core.Repo.preload([room: [:creator]])
    |> case do
      nil ->
        socket
      record ->
        socket
        |> stream_insert(
          :records,
          %{
            id: record.id,
            creator_name: record.room.creator.name,
            written_at: record.written_at,
            content: record.content,
            tags: record.tags
          },
          at: 0
        )
        |> assign(:record_count, count_records(socket.assigns))
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "export",
        _params,
        socket
      ) do
    {:noreply, redirect(socket, to: ~p"/export_messages")}
  end

  @impl true
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8">
      <div class="sm:flex sm:items-center">
        <div class="sm:flex-auto">
          <h1 class="text-base font-semibold leading-6 text-gray-900">Messages (<%= @record_count %>)</h1>
        </div>
        <div class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
          <button type="button" phx-click="export" class="block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
            Export
          </button>
        </div>
      </div>

      <div class="mt-8 flow-root">
        <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
            <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 sm:rounded-lg">
              <table class="min-w-full divide-y divide-gray-300">
                <thead class="bg-gray-50">
                  <tr>
                    <td scope="col" class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6">Chatroom</td>
                    <td scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Timestamp</td>
                    <td scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Tags</td>
                    <td scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Message</td>
                  </tr>
                </thead>
                <tbody id="messages" class="divide-y divide-gray-200 bg-white" phx-update="stream">
                  <tr :for={{dom_id, record} <- @streams.records} id={dom_id}>
                    <td class="py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6"><%= record.creator_name %></td>
                    <td class="px-3 py-4 text-sm text-gray-500"><%= record.written_at %></td>
                    <td class="px-3 py-4 text-sm text-gray-500"><%= Enum.join(record.tags, ", ") %></td>
                    <td class="px-3 py-4 text-sm text-gray-500"><%= record.content %></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
