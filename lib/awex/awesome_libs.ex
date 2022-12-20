defmodule Awex.AwesomeLibs do
  @moduledoc """
  The AwesomeLibs context.
  """

  import Ecto.Query, warn: false
  alias Awex.Repo

  alias Awex.AwesomeLibs.Lib

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