defmodule GVLWeb.PageController do
  use GVLWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
