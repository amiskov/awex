defmodule Awex.ParserFixtures do
  use Agent
  alias Awex.Parser

  # `temp.html` contains exact HTML from the GitHub Awesome Elixir repo.
  @html_stub Path.expand("stub.html", __DIR__)

  def start_link() do
    Agent.start_link(
      fn ->
        File.read!(@html_stub)
        |> Parser.parse_html()
        |> Parser.get_sections_with_libs()
      end,
      name: __MODULE__
    )
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end
end
