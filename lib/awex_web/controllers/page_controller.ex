defmodule AwexWeb.PageController do
  use AwexWeb, :controller

  alias Awex.AwesomeLibs

  def index(conn, %{"min_stars" => min_stars} = _params) do
    render(conn, "index.html",
      sections: AwesomeLibs.list_sections(min_stars),
      min_stars: min_stars
    )
  end

  def index(conn, _params) do
    sections = AwesomeLibs.list_sections()
    render(conn, "index.html", sections: sections, min_stars: 0)
  end
end
