defmodule Core.Chat do
  use Scaffolding, [Core.Chat.Creator, :creators, :creator]
  use Scaffolding, [Core.Chat.Room, :rooms, :room]
  use Scaffolding, [Core.Chat.Message, :messages, :message]

  def watch_chatrooms() do
    Core.Repo.all(Core.Chat.Room)
    |> Enum.each(fn room ->
      Core.Clients.KickChatroomClient.watch(room.external_chatroom_id)
    end)
  end
end
