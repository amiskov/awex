defmodule Awex.HtmlParser do
  alias Awex.{AwesomeSection, AwesomeLib}

  @moduledoc """
  Parse raw HTML into a map of `AwesomeSection`s.
  """

  def parse() do
    Awex.GitHub.get_html!()
    |> parse_html()
    |> extract_all_sections()
  end

  def parse_html(raw_html) do
    {:ok, document} = Floki.parse_document(raw_html)
    Floki.find(document, "article.markdown-body")
  end

  def extract_all_sections(html) do
    # table of contents (links to sections)
    toc =
      html
      |> Floki.find("article.markdown-body ul:first-of-type li:first-child > ul li a")
      |> Enum.map(fn a ->
        {"a", _, [name]} = a
        name
      end)

    Enum.reduce(toc, %{}, fn section_title, awesome_list ->
      extract_section(html, awesome_list, section_title)
    end)
  end

  def extract_section(html, section_libs, title) do
    desc = Floki.find(html, "h2:fl-contains(\"#{title}\")+p") |> Floki.text()

    libs =
      Floki.find(html, "h2:fl-contains(\"#{title}\")+p+ul li")
      |> Enum.map(fn li -> parse_lib(title, li) end)
      |> Map.new()

    Map.put(section_libs, title, %AwesomeSection{
      title: title,
      description: desc,
      libs: libs
    })
  end

  def parse_lib(section_title, li) do
    {"li", _, [link | rest]} = li
    desc = Floki.text(rest) |> String.replace_leading(" - ", "")
    {"a", [{_, href} | _], [name]} = link

    {name, %AwesomeLib{
      section: section_title,
      title: name,
      url: href,
      description: desc
      # stars and the last commit date are updated separately
    }}
  end
end
