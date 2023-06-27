# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Parry.Repo.insert!(%Parry.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, creator} = %Parry.Chat.Creator{}
|> Parry.Chat.Creator.changeset(%{
  name: "xqc",
  external_streamer_id: "668"
})
|> Parry.Repo.insert()

{:ok, room} = %Parry.Chat.Room{}
|> Parry.Repo.preload([:creator])
|> Parry.Chat.Room.changeset(%{
  creator: creator,
  external_chatroom_id: "668"
})
|> Parry.Repo.insert()
