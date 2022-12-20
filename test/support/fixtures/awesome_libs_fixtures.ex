defmodule Awex.AwesomeLibsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Awex.AwesomeLibs` context.
  """

  @doc """
  Generate a lib.
  """
  def lib_fixture(attrs \\ %{}) do
    {:ok, lib} =
      attrs
      |> Enum.into(%{

      })
      |> Awex.AwesomeLibs.create_lib()

    lib
  end
end
