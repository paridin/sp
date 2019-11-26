defmodule SpWeb.PageControllerTest do
  use SpWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Sp"
  end
end
