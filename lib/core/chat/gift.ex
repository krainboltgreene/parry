defmodule Core.Chat.Gift do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "gifts" do
    field :external_chatroom_id, :string
    field :gifted_usernames, {:array, :string}
    field :gifter_username, :string

    timestamps()
  end

  @doc false
  def changeset(gift, attrs) do
    gift
    |> cast(attrs, [:external_chatroom_id, :gifted_usernames, :gifter_username])
    |> validate_required([:external_chatroom_id, :gifted_usernames, :gifter_username])
  end
end
