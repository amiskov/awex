defmodule Awex.AwesomeLibsTest do
  use Awex.DataCase

  alias Awex.AwesomeLibs

  describe "libs" do
    alias Awex.AwesomeLibs.Lib

    import Awex.AwesomeLibsFixtures

    @invalid_attrs %{}

    test "list_libs/0 returns all libs" do
      lib = lib_fixture()
      assert AwesomeLibs.list_libs() == [lib]
    end

    test "get_lib!/1 returns the lib with given id" do
      lib = lib_fixture()
      assert AwesomeLibs.get_lib!(lib.id) == lib
    end

    test "create_lib/1 with valid data creates a lib" do
      valid_attrs = %{}

      assert {:ok, %Lib{} = lib} = AwesomeLibs.create_lib(valid_attrs)
    end

    test "create_lib/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AwesomeLibs.create_lib(@invalid_attrs)
    end

    test "update_lib/2 with valid data updates the lib" do
      lib = lib_fixture()
      update_attrs = %{}

      assert {:ok, %Lib{} = lib} = AwesomeLibs.update_lib(lib, update_attrs)
    end

    test "update_lib/2 with invalid data returns error changeset" do
      lib = lib_fixture()
      assert {:error, %Ecto.Changeset{}} = AwesomeLibs.update_lib(lib, @invalid_attrs)
      assert lib == AwesomeLibs.get_lib!(lib.id)
    end

    test "delete_lib/1 deletes the lib" do
      lib = lib_fixture()
      assert {:ok, %Lib{}} = AwesomeLibs.delete_lib(lib)
      assert_raise Ecto.NoResultsError, fn -> AwesomeLibs.get_lib!(lib.id) end
    end

    test "change_lib/1 returns a lib changeset" do
      lib = lib_fixture()
      assert %Ecto.Changeset{} = AwesomeLibs.change_lib(lib)
    end
  end
end
