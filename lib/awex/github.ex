defmodule Awex.GitHub do
  @awesome_list_url "https://github.com/h4cc/awesome-elixir/blob/master/README.md"

  @graphql_url "https://api.github.com/graphql"
  @gh_user_token "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"
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

  @section_query ~S"""
  query GetSectionReposInfo($repos: String!, $len: Int!) {
    search(query: $repos, type: REPOSITORY, first: $len, after: null) {
      repositoryCount
      nodes {
        ... on Repository {
          name
          url
          owner {
            login
          }
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

  def perform_gq_query(payload) do
    case HTTPoison.post(@graphql_url, payload, @graphql_query_headers) do
      {:ok, resp} ->
        result =
          resp.body
          |> Jason.decode!()
          |> Map.get("data")
          |> Map.get("search")

        # repos_count = Map.get(result, "repositoryCount")

        Map.get(result, "nodes")
        |> Enum.map(fn repo ->
          stars = Map.get(repo, "stargazers") |> Map.get("totalCount")
          url = Map.get(repo, "url") |> String.downcase()
          repo_name = Map.get(repo, "name")
          owner = Map.get(repo, "owner") |> Map.get("login")

          [%{"node" => %{"committedDate" => latest_commit}}] =
            repo
            |> Map.get("defaultBranchRef")
            |> Map.get("target")
            |> Map.get("history")
            |> Map.get("edges")

          {
            url,
            %{
              stars: stars,
              latest_commit: latest_commit,
              owner: owner,
              repo_name: repo_name,
              url: url
            }
          }
        end)
        |> Map.new()

      {:error, _resp} ->
        %{}
    end
  end

  def get_html!() do
    # File.read!(Path.join(File.cwd!(), "temp.html"))
    HTTPoison.get!(@awesome_list_url).body
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
        repo =
          resp.body
          |> Jason.decode!()
          |> Map.get("data")
          |> Map.get("repository")

        if repo do
          stars = Map.get(repo, "stargazers") |> Map.get("totalCount")

          [%{"node" => %{"committedDate" => latest_commit}}] =
            repo
            |> Map.get("defaultBranchRef")
            |> Map.get("target")
            |> Map.get("history")
            |> Map.get("edges")

          {:ok, dt, _} = DateTime.from_iso8601(latest_commit)

          {:ok,
           %{
             stars: stars,
             last_commit_datetime: dt
           }}
        else
          # TODO: handle different errors differently
          {:error, "repo not found"}
        end

      {:error, _resp} ->
        {:error, nil}
    end
  end
end
