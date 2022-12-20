defmodule AwexWeb.LibController do
  use AwexWeb, :controller

  alias Awex.AwesomeLibs
  alias Awex.AwesomeLibs.Lib

  def index(conn, _params) do
    libs = AwesomeLibs.list_libs()
    render(conn, "index.html", libs: libs)
  end

  def new(conn, _params) do
    changeset = AwesomeLibs.change_lib(%Lib{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"lib" => lib_params}) do
    case AwesomeLibs.create_lib(lib_params) do
      {:ok, lib} ->
        conn
        |> put_flash(:info, "Lib created successfully.")
        |> redirect(to: Routes.lib_path(conn, :show, lib))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    lib = AwesomeLibs.get_lib!(id)
    render(conn, "show.html", lib: lib)
  end

  def edit(conn, %{"id" => id}) do
    lib = AwesomeLibs.get_lib!(id)
    changeset = AwesomeLibs.change_lib(lib)
    render(conn, "edit.html", lib: lib, changeset: changeset)
  end

  def update(conn, %{"id" => id, "lib" => lib_params}) do
    lib = AwesomeLibs.get_lib!(id)

    case AwesomeLibs.update_lib(lib, lib_params) do
      {:ok, lib} ->
        conn
        |> put_flash(:info, "Lib updated successfully.")
        |> redirect(to: Routes.lib_path(conn, :show, lib))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", lib: lib, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    lib = AwesomeLibs.get_lib!(id)
    {:ok, _lib} = AwesomeLibs.delete_lib(lib)

    conn
    |> put_flash(:info, "Lib deleted successfully.")
    |> redirect(to: Routes.lib_path(conn, :index))
  end
end
