defmodule Awex.GitHub do
  @awesome_list_url "https://github.com/h4cc/awesome-elixir/blob/master/README.md"

  @graphql_url "https://api.github.com/graphql"
  @gh_user_token "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"
  @graphql_query_headers [Authorization: "Bearer #{@gh_user_token}", Accept: "Application/json; Charset=utf-8"]

  @stars_query ~S"""
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

  def get_html!() do
    File.read!(Path.join(File.cwd!(), "temp.html"))
    # HTTPoison.get!(@awesome_list_url).body
  end

  def get_stars_and_latest_commit!(owner, repo) do
    payload =
      %{
        variables: %{owner: owner, name: repo},
        query: @stars_query
      }
      |> Jason.encode!()

    case HTTPoison.post(@graphql_url, payload, @graphql_query_headers) do
      {:ok, resp} ->
        repo =
          resp.body
          |> Jason.decode!()
          |> Map.get("data")
          |> Map.get("repository")

        IO.inspect(resp.body, label: "Error somewhere here")
        stars = Map.get(repo, "stargazers") |> Map.get("totalCount")

        [%{"node" => %{"committedDate" => latest_commit}}] =
          repo
          |> Map.get("defaultBranchRef")
          |> Map.get("target")
          |> Map.get("history")
          |> Map.get("edges")

        {:ok, %{stars: stars, latest_commit: latest_commit}}

      {:error, _resp} ->
        {:error, nil}
    end
  end
end
