defmodule Awex.AwesomeLibs.Section do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sections" do
    field :title, :string

    has_many :lib, Awex.AwesomeLibs.Lib

    timestamps()
  end

  @doc false
  def changeset(section, attrs) do
    section
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
