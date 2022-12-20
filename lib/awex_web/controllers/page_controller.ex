defmodule AwexWeb.PageController do
  use AwexWeb, :controller

  alias Awex.AwesomeLibs

  def index(conn, _params) do
    libs = AwesomeLibs.list_libs()
    sections = AwesomeLibs.list_sections() |> Awex.Repo.preload(:libs)
    render(conn, "index.html", sections: sections, libs: libs)
  end
end
