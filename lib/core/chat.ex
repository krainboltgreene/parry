defmodule Core.Chat do
  import Ecto.Query

  def watch_chatrooms() do
    Core.Repo.all(Core.Chat.Room)
    |> Enum.each(fn room ->
      Core.Clients.KickChatroomClient.watch(room.external_chatroom_id)
    end)
  end
end
