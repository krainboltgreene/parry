defmodule Core.Chat.Message do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :content, :string
    field :external_message_id, :string
    field :external_username, :string
    field :written_at, :utc_datetime
    field :tags, {:array, :string}
    belongs_to :room, Core.Chat.Room, foreign_key: :external_chatroom_id, references: :external_chatroom_id, type: :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> Ecto.Changeset.cast(attrs, [:content, :external_chatroom_id, :external_username, :external_message_id, :written_at, :tags])
    |> Ecto.Changeset.validate_required([:content, :external_chatroom_id, :external_username, :external_message_id, :written_at, :tags])
  end

  def changeset_from_event(record, event) do
    {:ok, written_at, _} = DateTime.from_iso8601(event["created_at"])
    record
    |> Ecto.Changeset.cast(event, [:content])
    |> Ecto.Changeset.change(%{written_at: written_at})
    |> Ecto.Changeset.change(%{external_message_id: event["id"]})
    |> Ecto.Changeset.change(%{external_username: event["sender"]["username"]})
    |> Ecto.Changeset.change(%{tags: event["sender"]["identity"]["badges"] |> Enum.map(&Map.get(&1, "type"))})
    |> Ecto.Changeset.change(%{external_chatroom_id: Integer.to_string(event["chatroom_id"])})
    |> Ecto.Changeset.validate_required([:content, :external_chatroom_id, :external_username, :external_message_id, :written_at])
  end
end
