defmodule Awex.Repo.Migrations.AddLibsUnreachable do
  use Ecto.Migration

  def change do
    alter table(:libs) do
      add :unreachable, :boolean, default: false
    end
  end
end
