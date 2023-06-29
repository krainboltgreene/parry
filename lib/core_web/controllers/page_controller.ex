defmodule CoreWeb.PageController do
  use CoreWeb, :controller
  import Ecto.Query

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def export_messages(conn, _params) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"messages.csv\"")
    |> send_resp(200,
      from(
        messages in Core.Chat.Message,
        join: rooms in assoc(messages, :room),
        join: creators in assoc(rooms, :creator),
        select: [
          messages.written_at,
          creators.name,
          messages.external_username,
          messages.content,
          messages.tags,
          messages.id
        ],
        order_by: [desc: :written_at]
      )
      |> Core.Repo.all()
      |> Enum.map(fn [written_at, chatroom, username, content, tags, id] -> [written_at, chatroom, username, content, Enum.join(tags, "|"), id] end)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string()
    )
  end
end
