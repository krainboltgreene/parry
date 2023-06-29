defmodule Core.Chat.StreamUpdate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "stream_updates" do
    field :session_title, :string
    field :tags, {:array, :string}
    belongs_to :room, Core.Chat.Room, foreign_key: :external_chatroom_id, references: :external_chatroom_id, type: :string

    timestamps()
  end

  @doc false
  def changeset(stream_update, attrs) do
    stream_update
    |> cast(attrs, [:external_channel_id, :session_title, :tags])
    |> validate_required([:external_channel_id, :session_title, :tags])
  end

  def changeset_from_event(record, event) do
    record
    |> Ecto.Changeset.cast(event, [:session_title])
    |> Ecto.Changeset.change(%{tags: event["categories"] |> Enum.map(&Map.get(&1, "slug"))})
    |> Ecto.Changeset.change(%{external_chatroom_id: Integer.to_string(event["chatroom_id"])})
    |> Ecto.Changeset.validate_required([:session_title, :external_chatroom_id, :tags])
  end
end
