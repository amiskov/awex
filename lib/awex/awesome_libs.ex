defmodule Awex.AwesomeLibs do
  @moduledoc """
  The AwesomeLibs context.
  """

  import Ecto.Query, warn: false
  alias Awex.Repo

  alias Awex.AwesomeLibs.{Section, Lib}

  @doc "Returns a list of `owner/repo` strings, used in GitHub GraphQL query."
  def get_gh_section_repos(section_id) do
    Section
    |> Repo.get(section_id)
    |> Repo.preload(:libs)
    |> Map.get(:libs)
    |> Enum.filter(fn l ->
      l.url
      |> String.downcase
      |> String.starts_with?("https://github.com/")
    end)
    |> Enum.map(fn l ->
      %URI{path: path} = URI.parse(l.url)
      "repo:" <> String.trim_leading(path, "/")
    end)
  end

  def get_gh_repo(query) do
    
  end

  def update_section_repos(repos_info) do
    urls = repos_info |> Map.keys() |> Enum.map(&String.downcase/1)
    get_stars = fn url -> Map.get(repos_info, url) |> Map.get(:stars) end

    get_latest_commit_date = fn url ->
      datetime = Map.get(repos_info, url) |> Map.get(:latest_commit)
      {:ok, dt, _} = DateTime.from_iso8601(datetime)
      dt
    end

    query =
      from l in Lib,
      where: fragment("lower(?)", l.url) in ^urls

    libs = Repo.all(query) |> IO.inspect(label: "LIBS")

    # TODO: optimize this
    utc_datetime = DateTime.utc_now() |> DateTime.truncate(:second)
    for l <- libs do
      Ecto.Changeset.change(l,
        stars: get_stars.(String.downcase(l.url)),
        last_commit_datetime: get_latest_commit_date.(String.downcase(l.url)),
        updated_at: utc_datetime
      )
    end
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

  def get_gh_libs_for_update(limit) do
    hour_ago = DateTime.utc_now() |> DateTime.add(-1, :hour)
    query =
      from l in Lib,
        where: like(l.url, "https://github.com/%"),
        where: is_nil(l.updated_at), # or l.updated_at <= ^hour_ago,
        where: not(l.unreachable),
        # order_by: [asc_nulls_first: :updated_at, asc: :title],
        limit: ^limit
    Repo.all(query)
  end

  def get_repo_urls_for_update(limit) do
    # hour_ago = DateTime.utc_now() |> DateTime.add(-1, :hour)
    query =
      from l in Lib,
        where: like(l.url, "https://github.com/%"),
        where: is_nil(l.updated_at), # l.updated_at <= ^hour_ago or 
        # order_by: [asc_nulls_first: :updated_at, asc: :title],
        limit: ^limit,
        select: l.url
    Repo.all(query)
  end

  def list_sections do
    Section
    |> order_by(desc: :title)
    |> Repo.all()
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
  Inserts a lib if not exists, updates its attributes if exists.
  """
  def upsert_lib(attrs \\ %{}) do
    result =
      case Repo.get_by(Lib, title: attrs.title) do
        nil -> %Lib{}
        lib -> lib
      end
      |> Lib.changeset(attrs)
      |> Repo.insert_or_update!()
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
