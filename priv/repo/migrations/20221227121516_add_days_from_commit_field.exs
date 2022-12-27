defmodule Awex.Repo.Migrations.AddDaysFromCommitField do
  use Ecto.Migration

  def change do
    alter table(:libs) do
      add :days_from_last_commit, :integer
    end
  end
end
