defmodule GVLWeb.AddChordLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    I know about <%= length(@chords) %> chords.
    <button class="add-new-chord" phx-click="click">+ Add New Chord</button>
    """
  end

  def mount(params, socket) do
    {:ok,
     assign(
       socket,
       chords: params.chords,
       pid: params.pid
     )}
  end

  def handle_event("click", input, socket) do
    chords =
      socket.assigns.chords ++
        [
          %{
            heatmap:
              Chord.Heatmap.generate(0, [4, 3, 4, 1], List.last(socket.assigns.chords).playing),
            playing: [nil, nil, nil, nil, nil, nil],
            quality: [4, 3, 4, 1],
            quality_name: "maj7",
            root: 0,
            root_name: "C"
          }
        ]

    send(socket.assigns.pid, {:update_chords, chords})

    {:noreply, socket}
  end
end
