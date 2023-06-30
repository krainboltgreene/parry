defmodule Core.Chat do
  use Scaffolding, [Core.Chat.Creator, :creators, :creator]
  use Scaffolding, [Core.Chat.Room, :rooms, :room]
  use Scaffolding, [Core.Chat.Message, :messages, :message]
  use Scaffolding, [Core.Chat.Subscription, :subscriptions, :subscription]
  use Scaffolding, [Core.Chat.Gift, :gifts, :gift]

  def watch_chatrooms() do
    Core.Repo.all(Core.Chat.Room)
    |> Enum.each(fn room ->
      Core.Clients.KickChatroomClient.watch(room.external_chatroom_id)
    end)
  end

  def job_breakdown() do
    from(jobs in Oban.Job, group_by: [jobs.state], select: [jobs.state, count(jobs.id)]) |> Core.Repo.all
  end
end
