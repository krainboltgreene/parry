defmodule Parry.Repo.Migrations.CreateRoom do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :external_chatroom_id, :text, null: false
      add :creator_id, references(:creators, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:rooms, [:creator_id])
    create unique_index(:rooms, [:external_chatroom_id])
  end
end
