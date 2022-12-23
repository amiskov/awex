# Awex

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Further Improvement Ideas
We can use GraphQL API to make a batch query to update up to 100 libs at a time. It looks like this:

```graphql
query GetSectionReposInfo($repos: String!) {
  search(query: $repos, type: REPOSITORY, first: 100, after: null) {
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
### variables
{"repos": "repo:rmies/monad repo:... ..."}
```

 But looks like it doesn't support redirects for repos with changed owner/name. Single query does support redirects and that's because we use it now. Probably, we could update what we can with batch query and then fill in the gaps with single queries for libs with changed owner/name.