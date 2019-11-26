defmodule SpWeb.PageController do
  use SpWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
