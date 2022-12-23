defmodule Awex.AwesomeLibs do
  @moduledoc """
  The AwesomeLibs context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias Awex.Repo

  alias Awex.AwesomeLibs.{Section, Lib}

  def list_libs do
    Repo.all(Lib)
  end

  @doc """
  Clean the `sections` and `libs` tables restarting the `id` sequence.
  """
  def truncate_sections_with_libs() do
    Repo.query("TRUNCATE TABLE sections CASCADE;")

    Repo.query("ALTER SEQUENCE sections_id_seq RESTART WITH 1")
    Repo.query("UPDATE sections SET id = nextval('sections_id_seq');")

    Repo.query("ALTER SEQUENCE libs_id_seq RESTART WITH 1")
    Repo.query("UPDATE libs SET id = nextval('libs_id_seq');")

    Logger.info("`sections` and `libs` tables was truncated successfully.")
  end

  def add_sections(sections_with_libs) do
    for s <- sections_with_libs do
      case %Section{}
           |> Section.changeset(s)
           |> Repo.insert() do

        {:ok, %{id: section_id}} ->
          libs =
            s.libs
            |> Enum.map(fn l -> Map.put(l, :section_id, section_id) end)

          Ecto.Multi.new()
          |> Ecto.Multi.insert_all(:insert_all, Lib, libs, on_conflict: :nothing)
          |> Repo.transaction()

        {:error, err} ->
          Logger.error(err)
      end
    end
  end

  def update_lib_with_gh_info(lib, gh_info) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    attrs = Map.put(gh_info, :updated_at, now)

    lib
    |> Lib.changeset(attrs)
    |> Repo.update()
  end

  def mark_gh_lib_unreachable(lib) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    attrs = %{
      updated_at: now,
      unreachable: true
    }

    lib
    |> Lib.changeset(attrs)
    |> Repo.update()
  end

  def get_gh_libs_for_update(limit) do
    hour_ago = DateTime.utc_now() |> DateTime.add(-1, :hour)

    query =
      from l in Lib,
        where: like(l.url, "https://github.com/%"),
        where: is_nil(l.updated_at) or l.updated_at <= ^hour_ago,
        where: not l.unreachable,
        limit: ^limit

    Repo.all(query)
  end

  def list_sections do
    Section
    |> Repo.all()
  end
end
