defmodule Awex.Repo do
  use Ecto.Repo,
    otp_app: :awex,
    adapter: Ecto.Adapters.Postgres
end
