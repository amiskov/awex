defmodule Awex.Repo.Migrations.CreateLibs do
  use Ecto.Migration

  def change do
    create table(:libs) do
      add :title, :string
      add :description, :string
      add :url, :string
      add :stars, :integer
      add :last_commit_datetime, :utc_datetime
      add :section_id, references(:sections)

      # timestamps()
    end

    create unique_index(:libs, [:title, :url])
  end
end
