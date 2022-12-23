defmodule Awex.AwesomeLibs.Section do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sections" do
    field :title, :string
    field :description, :string

    has_many :libs, Awex.AwesomeLibs.Lib, preload_order: [asc: :title]
  end

  @doc false
  def changeset(section, attrs) do
    section
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
  end
end
