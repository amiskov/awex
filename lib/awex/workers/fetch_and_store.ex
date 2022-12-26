defmodule Awex.Workers.FetchAndStore do
  require Logger

  alias Awex.{GitHub, Parser, AwesomeList}

  @awesome_list_url Application.compile_env(:awex, :AWESOME_LIST_URL)
  @query_limit 99
  @timeout 1

  def run do
    Logger.info("Fetching HTML from #{@awesome_list_url}...")

    html =
      Task.async(fn -> GitHub.get_html!(@awesome_list_url) end)
      |> Task.await()

    Logger.info("Got HTML, parsing it...")
    sections_and_libs = parse(html)

    Logger.info("Refreshing the DB with a new list of repos...")
    refresh_db_data(sections_and_libs)

    Logger.info("Updating the DB with stars and latest commit dates...")
    update_libs_with_stars_and_last_commit_date()
  end

  defp parse(html) do
    html
    |> Parser.parse_html()
    |> Parser.get_sections_with_libs()
  end

  defp refresh_db_data(sections_and_libs) do
    AwesomeList.truncate_sections_and_libs_tables()
    AwesomeList.add_sections(sections_and_libs)
  end

  # For each lib send a GraphQL query to get stars and latest commit date.
  # NB: We don't use bulk GraphQL query (update many repos at the same time)
  # because this GitHub API doesn't handle redirects for libs with changed
  # name/owner. But with single query GitHub handles the redirects properly.
  def update_libs_with_stars_and_last_commit_date([_ | _] = gh_libs) do
    gh_libs
    |> Enum.map(fn lib ->
      Task.Supervisor.async_nolink(Awex.TaskSupervisor, fn -> update_lib(lib) end)
    end)
    |> Enum.map(&Task.await/1)
    |> (fn res ->
          case res do
            [:stop_querying_github] ->
              Supervisor.stop(Awex.TaskSupervisor)
              Logger.info("Supervisor for querying GitHub has been stopped!")

            _ ->
              :timer.sleep(@timeout * 1000)
              update_libs_with_stars_and_last_commit_date()
          end
        end).()
  end

  def update_libs_with_stars_and_last_commit_date([]),
    do: Logger.info("All libraries from GitHub has been updated.")

  def update_libs_with_stars_and_last_commit_date(),
    do:
      AwesomeList.get_gh_libs_for_update(@query_limit)
      |> update_libs_with_stars_and_last_commit_date

  defp update_lib(lib) do
    case Awex.GitHub.get_lib_info(lib.url) do
      {:ok, gh_info} ->
        AwesomeList.update_lib_with_gh_info(lib, gh_info)

      {:error, err} ->
        case err do
          [%{"type" => "NOT_FOUND"} | _] ->
            AwesomeList.mark_gh_lib_unreachable(lib)
            Logger.warning("Failed in `update_lib_with_gh_info`: #{lib.title} is unreachable.")
            :not_found

          [%{"type" => "RATE_LIMITED"} | _] ->
            :stop_querying_github

          _ ->
            Logger.error(to_string(err))
            :unhandled_error
        end
    end
  end
end
