defmodule Awex.GitHub do
  @awesome_list_url "https://github.com/h4cc/awesome-elixir/blob/master/README.md"

  @graphql_url "https://api.github.com/graphql"
  @gh_user_token "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"
  @graphql_query_headers [
    Authorization: "Bearer #{@gh_user_token}",
    Accept: "Application/json; Charset=utf-8"
  ]

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

  @section_query ~S"""
  query GetSectionReposInfo($repos: String!, $len: Int!) {
    search(query: $repos, type: REPOSITORY, first: $len, after: null) {
      repositoryCount
      nodes {
        ... on Repository {
          name
          stargazers {
            totalCount
          }
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
    }
  }
  """

  def prepare_section_gq_query(repos) do
    %{
      variables: %{repos: Enum.join(repos, " "), len: length(repos)},
      query: @section_query
    }
    |> Jason.encode!()
  end

  def perform_section_query(payload) do
    case HTTPoison.post(@graphql_url, payload, @graphql_query_headers) do
      {:ok, resp} ->
        result =
          resp.body
          |> Jason.decode!()
          |> Map.get("data")
          |> Map.get("search")

        repos_count = Map.get(result, "repositoryCount")

        repos_info =
          Map.get(result, "nodes")
          |> Enum.map(fn repo ->
            stars = Map.get(repo, "stargazers") |> Map.get("totalCount")

            [%{"node" => %{"committedDate" => latest_commit}}] =
              repo
              |> Map.get("defaultBranchRef")
              |> Map.get("target")
              |> Map.get("history")
              |> Map.get("edges")

            %{stars: stars, latest_commit: latest_commit}
          end)

        {:ok, %{repos_count: repos_count, repos_info: repos_info}}

      {:error, _resp} ->
        {:error, nil}
    end
  end

  def get_html!() do
    # File.read!(Path.join(File.cwd!(), "temp.html"))
    HTTPoison.get!(@awesome_list_url).body
  end

  def update_lib(lib) do
    if String.starts_with?(lib.url, "https://github.com/") do
      %URI{path: path} = URI.parse(lib.url)
      [owner, repo] = String.split(path, "/", trim: true) |> Enum.take(2)

      case Awex.GitHub.get_stars_and_latest_commit!(owner, repo) do
        {:ok, %{stars: s, latest_commit: d}} ->
          # Do the Repo.update
          lib
          |> Map.put(:stars, s)
          |> Map.put(:latest_commit, d)
      end
    else
      lib
    end
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
