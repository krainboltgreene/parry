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

{:ok, _} = %Core.Chat.Room{}
|> Core.Repo.preload([:creator])
|> Core.Chat.Room.changeset(%{
  creator: creator,
  external_chatroom_id: "668"
})
|> Core.Repo.insert()

{:ok, creator} = %Core.Chat.Creator{}
|> Core.Chat.Creator.changeset(%{
  name: "aidinross",
  external_streamer_id: "875396"
})
|> Core.Repo.insert()

{:ok, _} = %Core.Chat.Room{}
|> Core.Repo.preload([:creator])
|> Core.Chat.Room.changeset(%{
  creator: creator,
  external_chatroom_id: "875062"
})
|> Core.Repo.insert()

{:ok, creator} = %Core.Chat.Creator{}
|> Core.Chat.Creator.changeset(%{
  name: "Brucedropemoff",
  external_streamer_id: "677461"
})
|> Core.Repo.insert()

{:ok, _} = %Core.Chat.Room{}
|> Core.Repo.preload([:creator])
|> Core.Chat.Room.changeset(%{
  creator: creator,
  external_chatroom_id: "677223"
})
|> Core.Repo.insert()

{:ok, creator} = %Core.Chat.Creator{}
|> Core.Chat.Creator.changeset(%{
  name: "IcePoseidon",
  external_streamer_id: "145224"
})
|> Core.Repo.insert()

{:ok, _} = %Core.Chat.Room{}
|> Core.Repo.preload([:creator])
|> Core.Chat.Room.changeset(%{
  creator: creator,
  external_chatroom_id: "145222"
})
|> Core.Repo.insert()

{:ok, creator} = %Core.Chat.Creator{}
|> Core.Chat.Creator.changeset(%{
  name: "Amouranth",
  external_streamer_id: "7088698"
})
|> Core.Repo.insert()

{:ok, _} = %Core.Chat.Room{}
|> Core.Repo.preload([:creator])
|> Core.Chat.Room.changeset(%{
  creator: creator,
  external_chatroom_id: "7022952"
})
|> Core.Repo.insert()
