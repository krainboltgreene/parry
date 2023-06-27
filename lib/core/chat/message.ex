defmodule Core.Chat.Message do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :content, :string
    field :external_message_id, :string
    field :external_sender_id, :string
    field :written_at, :utc_datetime
    belongs_to :room, Core.Chat.Room, foreign_key: :external_chatroom_id, references: :external_chatroom_id, type: :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> Ecto.Changeset.cast(attrs, [:content, :external_chatroom_id, :external_sender_id, :external_message_id, :written_at])
    |> Ecto.Changeset.validate_required([:content, :external_chatroom_id, :external_sender_id, :external_message_id, :written_at])
  end

  def changeset_from_event(record, event) do
    {:ok, written_at, _} = DateTime.from_iso8601(event["created_at"])
    record
    |> Ecto.Changeset.cast(event, [:content])
    |> Ecto.Changeset.change(%{written_at: written_at})
    |> Ecto.Changeset.change(%{external_message_id: event["id"]})
    |> Ecto.Changeset.change(%{external_sender_id: Integer.to_string(event["sender"]["id"])})
    |> Ecto.Changeset.change(%{external_chatroom_id: Integer.to_string(event["chatroom_id"])})
    |> Ecto.Changeset.validate_required([:content, :external_chatroom_id, :external_sender_id, :external_message_id, :written_at])
  end
end
