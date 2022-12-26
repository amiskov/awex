defmodule Awex.ListTest do
  use Awex.DataCase

  alias Awex.List

  describe "libs" do
    alias Awex.List.Lib

    import Awex.ListFixtures

    @invalid_attrs %{}

    test "list_libs/0 returns all libs" do
      lib = lib_fixture()
      assert List.list_sections() == [lib]
    end

    test "get_lib!/1 returns the lib with given id" do
      lib = lib_fixture()
      assert List.get_lib!(lib.id) == lib
    end

    test "create_lib/1 with valid data creates a lib" do
      valid_attrs = %{}

      assert {:ok, %Lib{} = lib} = List.create_lib(valid_attrs)
    end

    test "create_lib/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = List.create_lib(@invalid_attrs)
    end

    test "update_lib/2 with valid data updates the lib" do
      lib = lib_fixture()
      update_attrs = %{}

      assert {:ok, %Lib{} = lib} = List.update_lib(lib, update_attrs)
    end

    test "update_lib/2 with invalid data returns error changeset" do
      lib = lib_fixture()
      assert {:error, %Ecto.Changeset{}} = List.update_lib(lib, @invalid_attrs)
      assert lib == List.get_lib!(lib.id)
    end

    test "delete_lib/1 deletes the lib" do
      lib = lib_fixture()
      assert {:ok, %Lib{}} = List.delete_lib(lib)
      assert_raise Ecto.NoResultsError, fn -> List.get_lib!(lib.id) end
    end

    test "change_lib/1 returns a lib changeset" do
      lib = lib_fixture()
      assert %Ecto.Changeset{} = List.change_lib(lib)
    end
  end
end
