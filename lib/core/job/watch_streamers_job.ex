defmodule Core.Job.WatchStreamersJob do
  use Oban.Worker
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Logger.info("Watching all chatrooms")
    Core.Chat.watch_chatrooms()

    __MODULE__.new(%{}, schedule_in: 30)
    |> Oban.insert()
  end
end
