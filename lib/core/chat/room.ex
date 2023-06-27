defmodule Core.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rooms" do
    field :external_chatroom_id, :string
    belongs_to :creator, Core.Chat.Creator
    has_many :messages, Core.Chat.Message, foreign_key: :external_chatroom_id, references: :external_chatroom_id

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:external_chatroom_id])
    |> validate_required([:external_chatroom_id])
    |> put_assoc(:creator, attrs[:creator] || room.creator)
  end
end
