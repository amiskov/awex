defmodule Awex.AwesomeListFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Awex.AwesomeList` context.
  """

  @doc """
  Generate a lib.
  """
  def lib_fixture(attrs \\ %{}) do
    {:ok, lib} =
      attrs
      |> Enum.into(%{})
      |> Awex.AwesomeList.create_lib()

    lib
  end
end
