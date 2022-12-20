defmodule Awex.Repo.Migrations.CreateSections do
  use Ecto.Migration

  def change do
    create table(:sections) do
      add :title, :string

      # timestamps()
    end

    create unique_index(:sections, [:title])
  end
end
