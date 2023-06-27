# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Core.Repo.insert!(%Core.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, creator} = %Core.Chat.Creator{}
|> Core.Chat.Creator.changeset(%{
  name: "xqc",
  external_streamer_id: "668"
})
|> Core.Repo.insert()

{:ok, room} = %Core.Chat.Room{}
|> Core.Repo.preload([:creator])
|> Core.Chat.Room.changeset(%{
  creator: creator,
  external_chatroom_id: "668"
})
|> Core.Repo.insert()
