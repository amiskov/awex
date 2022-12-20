defmodule AwexWeb.LibControllerTest do
  use AwexWeb.ConnCase

  import Awex.AwesomeLibsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all libs", %{conn: conn} do
      conn = get(conn, Routes.lib_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Libs"
    end
  end

  describe "new lib" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.lib_path(conn, :new))
      assert html_response(conn, 200) =~ "New Lib"
    end
  end

  describe "create lib" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.lib_path(conn, :create), lib: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.lib_path(conn, :show, id)

      conn = get(conn, Routes.lib_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Lib"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.lib_path(conn, :create), lib: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Lib"
    end
  end

  describe "edit lib" do
    setup [:create_lib]

    test "renders form for editing chosen lib", %{conn: conn, lib: lib} do
      conn = get(conn, Routes.lib_path(conn, :edit, lib))
      assert html_response(conn, 200) =~ "Edit Lib"
    end
  end

  describe "update lib" do
    setup [:create_lib]

    test "redirects when data is valid", %{conn: conn, lib: lib} do
      conn = put(conn, Routes.lib_path(conn, :update, lib), lib: @update_attrs)
      assert redirected_to(conn) == Routes.lib_path(conn, :show, lib)

      conn = get(conn, Routes.lib_path(conn, :show, lib))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, lib: lib} do
      conn = put(conn, Routes.lib_path(conn, :update, lib), lib: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Lib"
    end
  end

  describe "delete lib" do
    setup [:create_lib]

    test "deletes chosen lib", %{conn: conn, lib: lib} do
      conn = delete(conn, Routes.lib_path(conn, :delete, lib))
      assert redirected_to(conn) == Routes.lib_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.lib_path(conn, :show, lib))
      end
    end
  end

  defp create_lib(_) do
    lib = lib_fixture()
    %{lib: lib}
  end
end
