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
    |> unnest_data()
    |> handle_json_event(state)
  end

  def handle_frame({_type, _message}, state), do: {:ok, state}

  defp unnest_data({:ok, %{"data" => data} = payload}), do: {:ok, Map.put(payload, "data", Jason.decode(data))}
  defp unnest_data({:ok, payload}), do: {:ok, payload}
  defp unnest_data({:error, payload}), do: {:error, payload}

  defp handle_json_event({:ok, %{"event" => "pusher_internal:subscription_succeeded", "channel" => channel}}, %{currently_watching: currently_watching} = state) do
    state
    |> Map.put(:currently_watching, [channel | currently_watching])
    |> (&{:ok, &1}).()
  end

  # {"event":"App\\Events\\SubscriptionEvent","data":{"chatroom_id":668,"username":"terrenn","months":1},"channel":"chatrooms.668.v2"}?
  defp handle_json_event({:ok, %{"event" => "App\\Events\\ChannelSubscriptionEvent", "data" => {:ok, data}}}, state) do
    Logger.debug("Received subscription event")
    store(Core.Chat.Subscription, data)
    {:ok, state}
  end

  # {"event":"App\\Events\\GiftedSubscriptionsEvent","data":{"chatroom_id":92721,"gifted_usernames":["Duhzees"],"gifter_username":"TinyTwink"},"channel":"chatrooms.92721.v2"}
  defp handle_json_event({:ok, %{"event" => "App\\Events\\GiftedSubscriptionsEvent", "data" => {:ok, data}}}, state) do
    Logger.debug("Received gifted subscriptions event")
    store(Core.Chat.Gift, data)
    {:ok, state}
  end

  # {"event":"App\\Events\\ChatMessageEvent","data":{"id":"fe3a5338-e6be-4af7-a1f5-5c94b14d8570","chatroom_id":7022952,"content":"only if you can take a lot of hate and bullshit","type":"reply","created_at":"2023-06-28T23:11:45+00:00","sender":{"id":914599,"username":"kittencataubrey","slug":"kittencataubrey","identity":{"color":"#DEB2FF","badges":[{"type":"moderator","text":"Moderator"},{"type":"subscriber","text":"Subscriber","count":1}]}},"metadata":{"original_sender":{"id":"1649044","username":"duhkee"},"original_message":{"id":"518d2ef3-620c-4048-ade6-d0167ca52123","content":"would you recommend streaming?"}}},"channel":"chatrooms.7022952.v2"}
  defp handle_json_event({:ok, %{"event" => "App\\Events\\ChatMessageEvent", "data" => {:ok, data}}}, state) do
    Logger.debug("Received chat message event")
    store(Core.Chat.Message, data)
    {:ok, state}
  end

  # {"event":"App\\Events\\LivestreamUpdated","data":{"livestream":{"id":6348948,"slug":"8a38e-buffalo-hot-wings-challenge","channel_id":92723,"created_at":"2023-06-28 20:48:51","session_title":"[IRL] EATING HOTEST\ud83d\udd25 WINGS IN NA CHALLENGE\ud83d\udc14\ud83c\udf57 - Ice Poseidon in Jail #RipContentKing","is_live":true,"risk_level_id":null,"source":null,"twitch_channel":null,"duration":0,"language":"English","is_mature":false,"viewer_count":992,"tags":[],"categories":[{"id":15,"category_id":2,"name":"Just Chatting","SubscriptionEvent":"just-chatting","tags":["IRL"],"description":null,"deleted_at":null,"viewers":33360,"category":{"id":2,"name":"IRL","slug":"irl","icon":"\ud83c\udf99\ufe0f"}}]}},"channel":"private-livestream.6348948"}
  defp handle_json_event({:ok, %{"event" => "App\\Events\\LivestreamUpdated", "data" => {:ok, data}}}, state) do
    Logger.debug("Received chat message event #{inspect(data)}")
    store(Core.Chat.StreamUpdate, data)
    {:ok, state}
  end

  # {"event":"App\\Events\\UserBannedEvent","data":{"id":"eee6abd6-4cf7-4d10-8880-192dee4a7e3f","user":{"id":3042313,"username":"Re69aa","slug":"re69aa"},"banned_by":{"id":914599,"username":"kittencataubrey","slug":"kittencataubrey"},"expires_at":"2023-06-28T23:18:20+00:00"},"channel":"chatrooms.7022952.v2"}
  defp handle_json_event({:ok, _payload}, state), do: {:ok, state}

  defp store(model, data) when is_map(data) do
    Logger.debug("Storing data #{inspect(model)} #{inspect(data)}")
    model
    |> normalize(data)
    |> write()
    |> notify()
  end

  defp normalize(model, data) when is_map(data) do
    Logger.debug("Normalizing event")
    model.changeset_from_event(struct(model), data)
  end

  defp write(changeset) do
    Logger.debug("Writing event")
    Core.Repo.insert!(changeset)
  end

  defp notify(record) do
    Logger.debug("Broadcasting insert to chatroom-#{record.external_chatroom_id} for #{record.id}")
    CoreWeb.Endpoint.broadcast("chatroom-#{record.external_chatroom_id}", "message:insert", record.id)
    CoreWeb.Endpoint.broadcast("messages", "message:insert", record.id)
  end
end
