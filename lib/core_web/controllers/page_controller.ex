defmodule CoreWeb.PageController do
  use CoreWeb, :controller

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
      Core.Chat.list_events()
      |> Enum.map(fn [type, written_at, chatroom, username, content, tags, id] -> [written_at, chatroom, type, username, content, Enum.join(tags, "|"), id] end)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string()
    )
  end
end
