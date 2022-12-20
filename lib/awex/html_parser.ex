defmodule Awex.HtmlParser do
  alias Awex.{AwesomeSection, AwesomeLib}
  alias Awex.AwesomeLibs.{Section, Lib}

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
    sections =
      html
      |> Floki.find("article.markdown-body ul:first-of-type li:first-child > ul li a")
      |> Enum.map(fn a ->
        {"a", _, [name]} = a
        %{title: name}
      end)

    case Ecto.Multi.new()
         |> Ecto.Multi.insert_all(:insert_all, Section, sections)
         |> Awex.Repo.transaction() do
      {:ok, _} ->
        libs =
          Awex.Repo.all(Section)
          |> Enum.reduce([], fn section, awesome_list ->
            extract_section(html, awesome_list, section)
          end)
          |> List.flatten()

        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, Lib, libs)
        |> Awex.Repo.transaction()
    end
  end

  def extract_section(html, section_libs, section) do
    # TODO: section has a description
    desc = Floki.find(html, "h2:fl-contains(\"#{section.title}\")+p") |> Floki.text()

    libs =
      Floki.find(html, "h2:fl-contains(\"#{section.title}\")+p+ul li")
      |> Enum.map(fn li -> parse_lib(li, section.id) end)

    section_libs ++ [libs]

    # Map.put(section_libs, section.title, %AwesomeSection{
    #   title: section.title,
    #   description: desc,
    #   libs: libs
    # })
  end

  def parse_lib(li, section_id) do
    {"li", _, [link | rest]} = li
    desc = Floki.text(rest) |> String.replace_leading(" - ", "")
    {"a", [{_, href} | _], [name]} = link

    %{
      title: name,
      url: href,
      section_id: section_id,
      description: desc
      # stars and the last commit date are updated separately
    }
  end
end
