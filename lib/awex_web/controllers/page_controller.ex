defmodule AwexWeb.PageController do
  use AwexWeb, :controller

  alias Awex.AwesomeList

  def index(conn, %{"min_stars" => min_stars} = _params) do
    render(conn, "index.html",
      sections: AwesomeList.list_sections(min_stars),
      min_stars: min_stars
    )
  end

  def index(conn, _params) do
    sections = AwesomeList.list_sections()
    render(conn, "index.html", sections: sections, min_stars: 0)
  end
end
