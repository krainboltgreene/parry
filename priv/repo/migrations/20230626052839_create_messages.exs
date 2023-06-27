defmodule Parry.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text, null: false
      add :external_chatroom_id, references(:rooms, on_delete: :nothing, type: :text, column: :external_chatroom_id), null: false
      add :external_sender_id, :text, null: false
      add :external_message_id, :text, null: false
      add :written_at, :utc_datetime, null: false

      timestamps()
    end
    create index(:messages, [:external_chatroom_id])
    create index(:messages, [:external_sender_id])
    create unique_index(:messages, [:external_message_id])
  end
end
