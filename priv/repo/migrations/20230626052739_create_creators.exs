defmodule Core.Repo.Migrations.CreateCreators do
  use Ecto.Migration

  def change do
    create table(:creators, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :text, null: false
      add :external_streamer_id, :text, null: false

      timestamps()
    end

    create unique_index(:creators, [:external_streamer_id])
  end
end
