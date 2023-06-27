defmodule Parry.Chat do
  import Ecto.Query

  def watch_chatrooms() do
    Parry.Repo.all(Parry.Chat.Room)
    |> Enum.each(fn room ->
      Parry.Clients.KickChatroomClient.watch(room.external_chatroom_id)
    end)
  end
end
