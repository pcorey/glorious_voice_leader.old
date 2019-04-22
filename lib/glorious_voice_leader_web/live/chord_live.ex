defmodule GVLWeb.ChordLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="chord">

      <%= live_render(@socket, GVLWeb.ChordInputLive, session: %{
        index: @index,
        pid: @pid,
        chord: @chord,
        chords: @chords,
      }) %>

      <%= live_render(@socket, GVLWeb.FretboardLive, session: %{
        index: @index,
        pid: @pid,
        chord: @chord,
        chords: @chords,
      }) %>

    </div>
    """
  end

  def mount(params, socket) do
    {:ok,
     assign(
       socket,
       pid: params.pid,
       index: params.index,
       chord: params.chord,
       chords: params.chords
     )}
  end
end
