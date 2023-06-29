defmodule Core.Repo.Migrations.CreateStreamUpdates do
  use Ecto.Migration

  def change do
    create table(:stream_updates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :external_channel_id, :text, null: false
      add :session_title, :text, null: false
      add :tags, {:array, :text}, null: false, default: []

      timestamps()
    end
    create index(:stream_updates, [:external_channel_id])
  end
end
