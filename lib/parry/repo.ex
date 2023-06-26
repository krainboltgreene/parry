defmodule Parry.Repo do
  use Ecto.Repo,
    otp_app: :parry,
    adapter: Ecto.Adapters.Postgres
end
