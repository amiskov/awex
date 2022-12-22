defmodule Awex.Worker do
  use Task, restart: :transient

  alias Awex.AwesomeLibs, as: L
  alias Awex.AwesomeLibs.Lib

  @gh_limit_records 10

  def update_lib_with_gh_info(lib, gh_info) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    attrs = Map.put(gh_info, :updated_at, now)

    lib
    |> Lib.changeset(attrs)
    |> Awex.Repo.update()
  end

  def mark_gh_lib_unreachable(lib) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    attrs = %{
      updated_at: now,
      unreachable: true
    }

    lib
    |> Lib.changeset(attrs)
    |> Awex.Repo.update()
  end

  def run() do
    gh_libs = L.get_gh_libs_for_update(@gh_limit_records)

    if length(gh_libs) > 0 do
      gh_libs
      |> Enum.map(fn lib ->
        Task.async(fn -> update_lib(lib) end)
      end)
      |> Enum.map(&Task.await/1)
      |> (fn _res ->
            IO.puts("Bulk update finished. New will be started in 3 seconds...")
            :timer.sleep(3000)
            run()
          end).()
    else
      IO.puts("All libraries from GitHub are updated.")
    end
  end

  def update_lib(lib) do
    case Awex.GitHub.get_lib_info(lib.url) do
      {:ok, gh_info} ->
        update_lib_with_gh_info(lib, gh_info)

      {:error, _err} ->
        mark_gh_lib_unreachable(lib)
        IO.puts("Failed in `update_lib_with_gh_info`: #{lib.title} is unreachable.")
    end
  end
end
