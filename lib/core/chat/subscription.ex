defmodule Core.Chat.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subscriptions" do
    field :external_username, :string
    belongs_to :room, Core.Chat.Room, foreign_key: :external_chatroom_id, references: :external_chatroom_id, type: :string

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:external_chatroom_id, :external_username])
    |> validate_required([:external_chatroom_id, :external_username])
  end

  def changeset_from_event(record, event) do
    record
    |> Ecto.Changeset.change(%{external_chatroom_id: Integer.to_string(event["chatroom_id"])})
    |> Ecto.Changeset.change(%{external_username: event["username"]})
    |> Ecto.Changeset.validate_required([:external_chatroom_id, :external_username])
  end
end
