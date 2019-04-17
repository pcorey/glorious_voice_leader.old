defmodule GVLWeb.PageController do
  use GVLWeb, :controller

  def index(conn, params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      GVLWeb.PageLive,
      session: Map.get(params, "chords")
    )
  end
end
