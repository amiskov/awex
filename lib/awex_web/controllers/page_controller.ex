defmodule AwexWeb.PageController do
  use AwexWeb, :controller

  alias Awex.AA

  def index(conn, _params) do
    render(conn, "index.html", sections: AA.value())
  end
end
