defmodule Awex.GitHub do
  require Logger

  @graphql_url Application.compile_env(:awex, :GITHUB_GRAPHQL_URL)
  @gh_user_token Application.compile_env(:awex, :GITHUB_USER_TOKEN)
  @graphql_query_headers [
    Authorization: "Bearer #{@gh_user_token}",
    Accept: "Application/json; Charset=utf-8"
  ]
  @repo_query ~S"""
  query GetRepoInfo($owner: String!, $name: String!) {
    repository(owner: $owner, name: $name){
      stargazers {totalCount}
      defaultBranchRef {
        target {
          ... on Commit {
            history(first: 1) {
              edges {
                node {
                  committedDate
                }
              }
            }
          }
        }
      }
    }
  }
  """

  def get_html!(url) do
    # File.read!(Path.join(File.cwd!(), "temp.html"))
    HTTPoison.get!(url).body
  end

  def get_lib_info(gh_url) do
    %URI{path: path} = URI.parse(gh_url)
    [owner, repo] = String.split(path, "/", trim: true) |> Enum.take(2)

    payload =
      %{
        variables: %{owner: owner, name: repo},
        query: @repo_query
      }
      |> Jason.encode!()

    case HTTPoison.post(@graphql_url, payload, @graphql_query_headers) do
      {:ok, resp} ->
        resp =
          resp.body
          |> Jason.decode!()

        case resp do
          %{"errors" => errs} ->
            errs
            |> Enum.map(fn m ->
              Map.get(m, "type") <> ": " <> Map.get(m, "message")
            end)
            |> Logger.error()

            {:error, errs}

          _ ->
            repo =
              resp
              |> Map.get("data")
              |> Map.get("repository")

            if repo do
              stars = Map.get(repo, "stargazers") |> Map.get("totalCount")

              [%{"node" => %{"committedDate" => last_commit_date}}] =
                repo
                |> Map.get("defaultBranchRef")
                |> Map.get("target")
                |> Map.get("history")
                |> Map.get("edges")

              {:ok, dt, _} = DateTime.from_iso8601(last_commit_date)

              {:ok,
               %{
                 stars: stars,
                 last_commit_datetime: dt
               }}
            else
              Logger.error("repo not found")
              {:error, "repo not found"}
            end
        end

      {:error, %HTTPoison.Error{reason: reason, id: id}} ->
        Logger.error("HTTPoison error: id is #{id}; reason is `#{reason}`")
        {:error, reason}
    end
  end
end
