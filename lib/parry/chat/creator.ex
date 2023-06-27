defmodule Parry.Chat.Creator do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "creators" do
    field :external_streamer_id, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(creator, attrs) do
    creator
    |> Ecto.Changeset.cast(attrs, [:name, :external_streamer_id])
    |> Ecto.Changeset.validate_required([:name, :external_streamer_id])
  end
end
