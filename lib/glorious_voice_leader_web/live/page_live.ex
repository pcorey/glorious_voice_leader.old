defmodule GVLWeb.PageLive do
  use Phoenix.LiveView

  @root_options %{
    "C" => 0,
    "C#/Db" => 1,
    "D" => 2,
    "D#/Eb" => 3,
    "E" => 4,
    "F" => 5,
    "F#/Gb" => 6,
    "G" => 7,
    "G#/Ab" => 8,
    "A" => 9,
    "A#/Bb" => 10,
    "B" => 11
  }

  @quality_options %{
    "maj7" => [4, 3, 4, 1],
    "m7" => [3, 4, 3, 2],
    "m7b5" => [3, 3, 3, 3],
    "7" => [4, 3, 3, 2]
  }

  def render(assigns) do
    GVLWeb.PageView.render("index.html", assigns)
  end

  def mount(token, socket) do
    chords = initial_chords(token)

    {:ok,
     assign(
       socket,
       token: update_token(chords),
       chords: chords
     )}
  end

  defp initial_chords(nil) do
    [
      %{
        heatmap: Chord.Heatmap.generate(0, [4, 3, 4, 1], [nil, nil, nil, nil, nil, nil]),
        playing: [nil, nil, nil, nil, nil, nil],
        quality: [4, 3, 4, 1],
        quality_name: "maj7",
        root: 0,
        root_name: "C"
      }
    ]
  end

  defp initial_chords(chords) do
    chords =
      chords
      |> Base.decode64!()
      |> :erlang.binary_to_term()

    chords
    |> Enum.with_index()
    |> Enum.map(fn {chord, index} ->
      previous =
        if index == 0 do
          [nil, nil, nil, nil, nil, nil]
        else
          Enum.at(chords, index - 1).playing
        end

      chord
      |> Map.put_new(
        :root_name,
        @root_options
        |> Map.to_list()
        |> Enum.find(fn
          {_, root} -> root == chord.root
          _ -> false
        end)
        |> elem(0)
      )
      |> Map.put_new(
        :quality_name,
        @quality_options
        |> Map.to_list()
        |> Enum.find(fn
          {_, quality} -> quality == chord.quality
          _ -> false
        end)
        |> elem(0)
      )
      |> Map.put_new(
        :heatmap,
        Chord.Heatmap.generate(chord.root, chord.quality, chord.playing, previous)
      )
    end)
  end

  def handle_event("validate", input, socket) do
    {index, _} = Integer.parse(input["index"])
    root_name = input["root_name"]
    root = Map.get(@root_options, root_name)
    quality_name = input["quality_name"]
    quality = Map.get(@quality_options, quality_name)

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
              # Chord.Heatmap.generate(@root, @quality, @playing, Map.get(Enum.at(@chords, @index - 1), :playing, [nil, nil, nil, nil, nil, nil]) |> IO.inspect
          }
        )
      end

    {:noreply,
     socket
     |> assign(:chords, chords)
     |> assign(:token, update_token(chords))}
  end

  def handle_event("click_fret", input, socket) do
    {index, string, fret, value} =
      input
      |> Base.decode64!()
      |> :erlang.binary_to_term()

    previous =
      if index == 0 do
        [nil, nil, nil, nil, nil, nil]
      else
        Enum.at(socket.assigns.chords, index - 1).playing
      end

    chords =
      socket.assigns.chords
      |> List.update_at(index, fn chord ->
        playing = List.replace_at(chord.playing, string, value)

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

    {:noreply,
     socket
     |> assign(:chords, chords)
     |> assign(:token, update_token(chords))}
  end

  def handle_event("add_new_chord", input, socket) do
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

    {:noreply,
     socket
     |> assign(:chords, chords)
     |> assign(:token, update_token(chords))}
  end

  defp update_token(chords) do
    chords
    |> Enum.map(
      &%{
        playing: &1.playing,
        quality: &1.quality,
        root: &1.root
      }
    )
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end
end
