defmodule Awex.ListFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Awex.List` context.
  """

  @doc """
  Generate a lib.
  """
  def lib_fixture(attrs \\ %{}) do
    {:ok, lib} =
      attrs
      |> Enum.into(%{

      })
      |> Awex.List.create_lib()

    lib
  end
end
