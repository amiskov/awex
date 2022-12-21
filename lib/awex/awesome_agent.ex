defmodule Awex.AA do
  use Agent
  alias Awex.HtmlParser

  def start_link(state \\ []) do
    Agent.start_link(fn -> state end, name: __MODULE__)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  @doc "Updates the state from the give html."
  def update_from_html() do
    state = HtmlParser.parse()
    Agent.update(__MODULE__, fn _ -> state end)
  end

  def update_from_github() do
    Agent.update(__MODULE__, fn alist ->
      alist
      |> Enum.each(&update_section/1)
    end)
  end

  defp update_section(section) do
    new_libs =
      section
      |> Map.get(:libs)
      |> Enum.map(&Awex.GitHub.update_lib/1)

    %{section | libs: new_libs}
  end


  # Supervisor.start_link([{Awex.Worker, nil}], strategy: :one_for_one)
end
