defmodule Core.Chat do
  use Scaffolding, [Core.Chat.Creator, :creators, :creator]
  use Scaffolding, [Core.Chat.Room, :rooms, :room]
  use Scaffolding, [Core.Chat.Message, :messages, :message]
  use Scaffolding, [Core.Chat.Subscription, :subscriptions, :subscription]
  use Scaffolding, [Core.Chat.Gift, :gifts, :gift]

  @type_to_model_mapping %{
    messages: Core.Chat.Message,
    subscriptions: Core.Chat.Subscription,
    gifts: Core.Chat.Gift
  }
  @types @type_to_model_mapping |> Map.keys()

  def watch_chatrooms() do
    Core.Repo.all(Core.Chat.Room)
    |> Enum.each(fn room ->
      Core.Clients.KickChatroomClient.watch(room.external_chatroom_id)
    end)
  end

  def list_events() do
    from(
      events in subquery(
        from(
          messages in Core.Chat.Message,
          join: rooms in assoc(messages, :room),
          join: creators in assoc(rooms, :creator),
          select: %{
            type: "message",
            written_at: messages.written_at,
            chatroom: creators.name,
            username: messages.external_username,
            content: messages.content,
            tags: messages.tags,
            id: messages.id
          },
          union_all:
            ^from(
              gifts in Core.Chat.Gift,
              join: rooms in assoc(gifts, :room),
              join: creators in assoc(rooms, :creator),
              select: %{
                type: "gift",
                written_at: gifts.inserted_at,
                chatroom: creators.name,
                username: gifts.gifter_username,
                content: ^"",
                tags: gifts.gifted_usernames,
                id: gifts.id
              },
              union_all:
                ^from(
                  subscriptions in Core.Chat.Subscription,
                  join: rooms in assoc(subscriptions, :room),
                  join: creators in assoc(rooms, :creator),
                  select: %{
                    type: "subscription",
                    written_at: subscriptions.inserted_at,
                    chatroom: creators.name,
                    username: subscriptions.external_username,
                    content: ^"",
                    tags: ^[],
                    id: subscriptions.id
                  }
                )
            )
        )
      ),
      select: [
        events.type,
        events.written_at,
        events.chatroom,
        events.username,
        events.content,
        events.tags,
        events.id
      ],
      order_by: [desc: :written_at]
    )
    |> Core.Repo.all()
  end

  def creator_rooms() do
    Core.Chat.list_rooms()
    |> Core.Repo.preload([:creator])
    |> Enum.map(fn room ->
      {room.creator.name, room}
    end)
  end

  def gifted_subscriptions_breakdown() do
    creator_rooms()
    |> Enum.map(fn {name, room} ->
      {
        name,
        {
          from(
            gifts in Core.Chat.Gift,
            where: [
              external_chatroom_id: ^room.external_chatroom_id
            ]
          )
          |> Core.Repo.all()
          |> Enum.flat_map(fn gift -> gift.gifted_usernames end)
          |> length()
        }
      }
    end)
    |> Map.new()
  end

  def most_common_nonemote_strict_message() do
    creator_rooms()
    |> Enum.map(fn {name, room} ->
      {
        name,
        {
          from(
            messages in Core.Chat.Message,
            where: [
              external_chatroom_id: ^room.external_chatroom_id
            ],
            where: not ilike(messages.content, "[emote:%"),
            select: [
              messages.content,
              count(messages.id)
            ],
            group_by: [
              messages.content
            ],
            order_by: [
              desc: 2
            ],
            limit: 5
          )
          |> Core.Repo.all()
          |> Enum.map(fn [message, count] -> {message, count} end)
          |> Map.new()
        }
      }
    end)
    |> Map.new()
  end

  def emoji_breakdown() do
    creator_rooms()
    |> Enum.map(fn {name, room} ->
      {
        name,
        {
          from(
            messages in Core.Chat.Message,
            where: messages.external_chatroom_id == ^room.external_chatroom_id,
            where: ilike(messages.content, "[emote:%")
          )
          |> Core.Repo.aggregate(:count),
          from(
            messages in Core.Chat.Message,
            where: messages.external_chatroom_id == ^room.external_chatroom_id
          )
          |> Core.Repo.aggregate(:count)
        }
      }
    end)
    |> Enum.map(fn {name, {emote_count, total}} ->
      {name, {emote_count, total, Float.round(emote_count / total * 100.0, 3)}}
    end)
    |> Map.new()
  end

  def event_breakdown() do
    creator_rooms()
    |> Enum.map(fn {name, room} ->
      {
        name,
        @types
        |> Enum.map(fn type -> {type, Map.get(@type_to_model_mapping, type)} end)
        |> Enum.map(fn {type, model} ->
          {
            type,
            from(
              model,
              where: [
                external_chatroom_id: ^room.external_chatroom_id
              ]
            )
            |> Core.Repo.aggregate(:count)
          }
        end)
        |> Map.new()
      }
    end)
    |> Map.new()
  end

  def job_breakdown() do
    from(jobs in Oban.Job, group_by: [jobs.state], select: [jobs.state, count(jobs.id)])
    |> Core.Repo.all()
  end
end
