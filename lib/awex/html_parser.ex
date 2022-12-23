defmodule Awex.HtmlParser do
  def parse_html(raw_html) do
    {:ok, document} = Floki.parse_document(raw_html)
    Floki.find(document, "article.markdown-body")
  end

  def get_sections_with_libs(html) do
    html
    |> Floki.find("article.markdown-body ul:first-of-type li:first-child > ul li a")
    |> Enum.map(&get_section_name/1)
    |> Enum.map(fn sname -> add_desc_and_libs(html, sname) end)
  end

  defp add_desc_and_libs(html, title) do
    desc =
      html
      |> Floki.find("h2:fl-contains(\"#{title}\")+p")
      |> Floki.text()

    libs =
      html
      |> Floki.find("h2:fl-contains(\"#{title}\")+p+ul li")
      |> Enum.map(&get_lib/1)

    %{
      title: title,
      description: desc,
      libs: libs
    }
  end

  defp get_section_name(a) do
    {"a", _, [name]} = a
    name
  end

  defp get_lib(li) do
    {"li", _, [link | rest]} = li
    desc = Floki.text(rest) |> String.replace_leading(" - ", "")
    {"a", [{_, href} | _], [name]} = link

    %{
      title: name,
      url: href,
      description: desc
    }
  end
end
