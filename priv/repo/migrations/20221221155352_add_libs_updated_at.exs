defmodule Awex.Repo.Migrations.AddLibsUpdatedAt do
  use Ecto.Migration

  def change do
    alter table(:libs) do
      add :updated_at, :utc_datetime
    end
  end
end
