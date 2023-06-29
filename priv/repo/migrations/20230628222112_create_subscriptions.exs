defmodule Core.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :external_chatroom_id, :text, null: false
      add :external_username, :text, null: false

      timestamps()
    end
    create index(:subscriptions, [:external_chatroom_id])
    create index(:subscriptions, [:external_username])
  end
end
