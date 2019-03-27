defmodule GVLWeb.PageController do
  use GVLWeb, :controller

  def index(conn, _) do
    Phoenix.LiveView.Controller.live_render(conn, GVLWeb.PageLive, session: %{})
  end
end
