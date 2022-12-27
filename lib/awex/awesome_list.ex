defmodule Awex.AwesomeList do
  @moduledoc """
  The List context.
  """

  require Logger

  import Ecto.Query, warn: false

  alias Awex.Repo
  alias Awex.AwesomeList.{Section, Lib}

  @doc """
  Clean the `sections` and `libs` tables restarting the `id` sequence.
  """
  def truncate_sections_and_libs_tables() do
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
    diff = Date.diff(now, gh_info.last_commit_datetime)

    attrs =
      gh_info
      |> Map.put(:updated_at, now)
      |> Map.put(:days_from_last_commit, diff)

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
    query =
      from l in Lib,
        where: like(l.url, "https://github.com/%"),
        # Get only those libs which weren't recently updated
        # or weren't updated at all:
        where: is_nil(l.updated_at) or l.updated_at <= ago(1, "hour"),
        where: not l.unreachable,
        limit: ^limit

    Repo.all(query)
  end

  def list_sections do
    Section
    |> preload(:libs)
    |> Repo.all()
  end

  def list_sections(min_stars) do
    q =
      from s in Section,
        join: l in assoc(s, :libs),
        where: l.stars >= ^min_stars,
        preload: [libs: l]

    Repo.all(q)
  end

  @doc """
  Returns the list of libs.

  ## Examples

      iex> list_libs()
      [%Lib{}, ...]

  """
  def list_libs do
    Repo.all(Lib)
  end

  @doc """
  Gets a single lib.

  Raises `Ecto.NoResultsError` if the Lib does not exist.

  ## Examples

      iex> get_lib!(123)
      %Lib{}

      iex> get_lib!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lib!(id), do: Repo.get!(Lib, id)

  @doc """
  Creates a lib.

  ## Examples

      iex> create_lib(%{field: value})
      {:ok, %Lib{}}

      iex> create_lib(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lib(attrs \\ %{}) do
    %Lib{}
    |> Lib.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lib.

  ## Examples

      iex> update_lib(lib, %{field: new_value})
      {:ok, %Lib{}}

      iex> update_lib(lib, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lib(%Lib{} = lib, attrs) do
    lib
    |> Lib.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lib.

  ## Examples

      iex> delete_lib(lib)
      {:ok, %Lib{}}

      iex> delete_lib(lib)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lib(%Lib{} = lib) do
    Repo.delete(lib)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lib changes.

  ## Examples

      iex> change_lib(lib)
      %Ecto.Changeset{data: %Lib{}}

  """
  def change_lib(%Lib{} = lib, attrs \\ %{}) do
    Lib.changeset(lib, attrs)
  end
end
