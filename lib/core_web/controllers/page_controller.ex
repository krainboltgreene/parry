defmodule CoreWeb.PageController do
  use CoreWeb, :controller
  import Ecto.Query

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def export_messages(conn, _params) do
    subscription_query = from(
        subscriptions in Core.Chat.Subscription,
        join: rooms in assoc(subscriptions, :room),
        join: creators in assoc(rooms, :creator),
        select: %{
          written_at: subscriptions.inserted_at,
          chatroom: creators.name,
          username: subscriptions.external_username,
          content: ^"subscription",
          tags: ^[],
          id: subscriptions.id,
        }
      )
    gift_query = from(
      gifts in Core.Chat.Gift,
      join: rooms in assoc(gifts, :room),
      join: creators in assoc(rooms, :creator),
      select: %{
        written_at: gifts.inserted_at,
        chatroom: creators.name,
        username: gifts.gifter_username,
        content: ^"gift",
        tags: gifts.gifted_usernames,
        id: gifts.id,
      },
      union_all: ^subscription_query
    )
    message_query = from(
      messages in Core.Chat.Message,
      join: rooms in assoc(messages, :room),
      join: creators in assoc(rooms, :creator),
      select: %{
        written_at: messages.written_at,
        chatroom: creators.name,
        username: messages.external_username,
        content: messages.content,
        tags: messages.tags,
        id: messages.id,
      },
      union_all: ^gift_query
    )
    events_query = from(
        events in subquery(message_query),
        select: [
          events.written_at,
          events.chatroom,
          events.username,
          events.content,
          events.tags,
          events.id,
        ],
        order_by: [desc: :written_at]
      )

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"messages.csv\"")
    |> send_resp(200,
      events_query
      |> Core.Repo.all()
      |> Enum.map(fn [written_at, chatroom, username, content, tags, id] -> [written_at, chatroom, username, content, Enum.join(tags, "|"), id] end)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string()
    )
  end
end
