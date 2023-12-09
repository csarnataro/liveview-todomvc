defmodule TodoMvc.Repo do
  use Ecto.Repo,
    otp_app: :todo_mvc,
    adapter: Ecto.Adapters.Postgres
end
