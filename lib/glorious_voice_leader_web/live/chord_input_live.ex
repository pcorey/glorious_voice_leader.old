defmodule GVLWeb.ChordInputLive do
  use Phoenix.HTML
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <%= f = form_for %Plug.Conn{}, "#", [phx_change: :validate] %>

      <div class="selects">
        <%= hidden_input f,
            :index,
            value: @index %>
        <%= select f,
            :root_name,
            root_options(),
            value: @chord.root_name %>
        <%= select f,
            :quality_name,
            quality_options(),
            value: @chord.quality_name %>
      </div>

      <div class="buttons">
        <button phx-click="clear_fretboard" phx-value="<%= @index %>">clear</button>
        <%= if @index != 0 do %>
          <button phx-click="remove_fretboard" phx-value="<%= @index %>">remove</button>
        <%= end %>
        <button onclick="play(<%= @index %>, <%= inspect(midi(@chord.playing), char_lists: :as_lists) %>)" type="button">play</button>
      </div>

      <script>
        function play(index, playing) {
          console.log(index, playing);
          let notes = playing.map(midi => new Tone.Frequency(midi, "midi"))
          synth.triggerAttackRelease(notes, 0.25, undefined, 0.25);
        }
      </script>
    </form>
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

  def handle_event("validate", input, socket) do
    {index, _} = Integer.parse(input["index"])
    root_name = input["root_name"]
    root = Map.get(Chord.Root.options(), root_name)
    quality_name = input["quality_name"]
    quality = Map.get(Chord.Quality.options(), quality_name)

    previous =
      if index == 0 do
        [nil, nil, nil, nil, nil, nil]
      else
        Enum.at(socket.assigns.chords, index - 1).playing
      end

    chords =
      socket.assigns.chords
      |> List.update_at(
        index,
        &%{
          heatmap: Chord.Heatmap.generate(root, quality, &1.playing, previous),
          playing: &1.playing,
          quality: quality,
          quality_name: quality_name,
          root: root,
          root_name: root_name
        }
      )

    chords =
      if index == length(chords) - 1 do
        chords
      else
        chords
        |> List.update_at(
          index + 1,
          &%{
            &1
            | heatmap:
                Chord.Heatmap.generate(
                  &1.root,
                  &1.quality,
                  &1.playing,
                  Enum.at(chords, index).playing
                )
          }
        )
      end

    send(socket.assigns.pid, {:update_chords, chords})

    {:noreply, socket}
  end

  def handle_event("clear_fretboard", input, socket) do
    {index, _} = Integer.parse(input)

    previous =
      if index == 0 do
        [nil, nil, nil, nil, nil, nil]
      else
        Enum.at(socket.assigns.chords, index - 1).playing
      end

    chords =
      socket.assigns.chords
      |> List.update_at(index, fn chord ->
        playing = [nil, nil, nil, nil, nil, nil]

        %{
          chord
          | playing: playing,
            heatmap: Chord.Heatmap.generate(chord.root, chord.quality, playing, previous)
        }
      end)

    chords =
      if index == length(chords) - 1 do
        chords
      else
        chords
        |> List.update_at(
          index + 1,
          &%{
            &1
            | heatmap:
                Chord.Heatmap.generate(
                  &1.root,
                  &1.quality,
                  &1.playing,
                  Enum.at(chords, index).playing
                )
          }
        )
      end

    send(socket.assigns.pid, {:update_chords, chords})

    {:noreply, socket}
  end

  def handle_event("remove_fretboard", input, socket) do
    {index, _} = Integer.parse(input)

    previous =
      if index == 0 do
        [nil, nil, nil, nil, nil, nil]
      else
        Enum.at(socket.assigns.chords, index - 1).playing
      end

    chords =
      socket.assigns.chords
      |> List.delete_at(index)

    chords =
      if index == length(chords) do
        chords
      else
        chords
        |> List.update_at(
          index,
          &%{
            &1
            | heatmap:
                Chord.Heatmap.generate(
                  &1.root,
                  &1.quality,
                  &1.playing,
                  Enum.at(chords, index - 1).playing
                )
          }
        )
      end

    send(socket.assigns.pid, {:update_chords, chords})

    {:noreply, socket}
  end

  def root_options do
    Chord.Root.options()
    |> Map.keys()
  end

  def quality_options do
    Chord.Quality.options()
    |> Map.keys()
  end

  def midi(playing) do
    playing
    |> Enum.zip([40, 45, 50, 55, 59, 64])
    |> Enum.reject(fn
      {nil, _} -> true
      _ -> false
    end)
    |> Enum.map(fn {fret, open} -> fret + open end)
  end
end
