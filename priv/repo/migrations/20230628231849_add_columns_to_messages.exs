defmodule Core.Repo.Migrations.AddColumnsToMessages do
  use Ecto.Migration

  def change do
    alter(table(:messages)) do
      add(:tags, {:array, :text}, null: false, default: [])
    end
    rename table(:messages), :external_sender_id, to: :external_username
  end
end
