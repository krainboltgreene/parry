defmodule Core.Job.UpdateOldUsernameJob do
  use Oban.Worker
  import Ecto.Query

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"username" => username, "id" => id} = args}) do
    from(
      Core.Chat.Message,
      where: [
        external_username: ^Integer.to_string(id)
      ]
    )
    |> Core.Repo.all()
    |> Enum.each(fn record ->
      record
      |> Core.Chat.Message.changeset(%{external_username: username})
      |> Core.Repo.update!()
    end)
  end
end
