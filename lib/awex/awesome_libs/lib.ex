defmodule Awex.AwesomeLibs.Lib do
  use Ecto.Schema
  import Ecto.Changeset

  schema "libs" do
    field :title, :string
    field :url, :string
    field :stars, :integer
    field :last_commit_datetime, :utc_datetime
    field :description, :string

    belongs_to :sections, Awex.AwesomeLibs.Section #, foreign_key: :section_id, references: :id, define_field: false

    timestamps()
  end

  @doc false
  def changeset(lib, attrs) do
    lib
    |> cast(attrs, [:title, :description, :url, :stars, :last_commit_datetime])
    |> unique_constraint(:title, message: "Lib title already exists")
    |> validate_required([:title, :url, :description])
  end
end
