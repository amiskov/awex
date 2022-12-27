defmodule Awex.GithubTest do
  use Awex.DataCase, async: true

  alias Awex.AwesomeList
  alias Awex.Workers.FetchAndStore

  describe "communication with github" do
    test "update stars and last commit date from GitHub" do
      # It's highly likely that Phoenix will not be abandoned,
      # so we can get some stats directly from GitHub and do some checks.
      %{
        title: "phoenix",
        url: "https://github.com/phoenixframework/phoenix",
        description: "Elixir Web Framework..."
      }
      |> AwesomeList.create_lib()

      # Update Phoenix library directly from GitHub
      FetchAndStore.update_libs_with_stars_and_last_commit_date()

      updated_phoenix = hd(AwesomeList.list_libs())

      assert updated_phoenix.days_from_last_commit >= 0
      assert updated_phoenix.updated_at != nil
      assert updated_phoenix.last_commit_datetime != nil
      assert updated_phoenix.unreachable == false
    end
  end
end
