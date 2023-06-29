defmodule Core.Repo.Migrations.CreateGifts do
  use Ecto.Migration

  def change do
    create table(:gifts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :external_chatroom_id, :text, null: false
      add :gifted_usernames, {:array, :text}, null: false
      add :gifter_username, :text, null: false

      timestamps()
    end
    create index(:gifts, [:external_chatroom_id])
    create index(:gifts, [:gifter_username])
  end
end
