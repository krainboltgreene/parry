defmodule Core.Clients.KickChatroomClient do
  use WebSockex
  require Logger

  @socket "wss://ws-us2.pusher.com/app/eb1d5f283081a78b932c?protocol=7&client=js&version=7.6.0&flash=false"
  def start_link(opts \\ []) do
    WebSockex.start_link(
      @socket,
      __MODULE__,
      %{currently_watching: []},
      Keyword.merge(
        [
          name: __MODULE__,
          # debug: [:trace],
          extra_headers: [
            {"accept-language", "en-US,en;q=0.9"},
            {"cache-control", "no-cache"},
            {"pragma", "no-cache"}
          ]
        ],
        opts
      )
    )
  end

  def get_currently_watching() do
    :ok = WebSockex.cast(__MODULE__, {:get_currently_watching, self()})

    receive do
      msg -> msg
    after
      200 -> raise "State didn't return after 200ms"
    end
  end

  def watch(chatroom) do
    Logger.debug("Connecting to chatroom #{chatroom}")
    WebSockex.send_frame(
      __MODULE__,
      {
        :text,
        Jason.encode!(
          %{
            "event" => "pusher:subscribe",
            "data" => %{
              "auth" => "",
              "channel" => "chatrooms.#{chatroom}.v2"
            }
          }
        )
      }
    )
  end

  def handle_cast({:get_currently_watching, pid}, state) do
    send(pid, state[:currently_watching])

    {:ok, state}
  end

  def handle_disconnect(_connection_status_map, state) do
    state
    |> Map.put(:currently_watching, [])
    |> (&{:reconnect, &1}).()
  end

  def handle_frame({:text, raw}, state) do
    Logger.debug("Received text frame")
    raw
    |> Jason.decode()
    |> handle_json_event(state)
  end

  def handle_frame({_type, _message}, state), do: {:ok, state}

  defp handle_json_event({:ok, %{"event" => "pusher_internal:subscription_succeeded", "channel" => channel}}, %{currently_watching: currently_watching} = state) do
    state
    |> Map.put(:currently_watching, [channel | currently_watching])
    |> (&{:ok, &1}).()
  end

  defp handle_json_event({:ok, %{"event" => "App\\Events\\ChatMessageEvent", "data" => data}}, state) do
    Logger.debug("Received chat message event")
    data
    |> Jason.decode()
    |> normalize()
    |> write()
    |> notify()

    {:ok, state}
  end

  defp handle_json_event({:ok, _json}, state), do: {:ok, state}

  defp normalize({:ok, data}) do
    Logger.debug("Normalizing event")
    Core.Chat.Message.changeset_from_event(%Core.Chat.Message{}, data)
  end

  defp write(changeset) do
    Logger.debug("Writing event")
    Core.Repo.insert!(changeset)
  end

  defp notify(record) do
    Logger.debug("Broadcasting insert to chatroom-#{record.external_chatroom_id} for #{record.id}")
    CoreWeb.Endpoint.broadcast("chatroom-#{record.external_chatroom_id}", "insert", record.id)
  end
end
