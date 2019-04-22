defmodule GVLWeb.FretLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <div class='fret <%= fret_classes(@string, @fret, @chord.playing, @freq) %>'
           style='color: <%= fret_color(@string, @fret, @freq) %>; background-color: <%= fret_background_color(@string, @fret, @freq) %>'
           phx-click="click_fret"
           phx-value=<%= {@index, @string, @fret, if Enum.at(@chord.playing, @string) == @fret do nil else @fret end} |> :erlang.term_to_binary() |> Base.encode64() %>></div>
    """
  end

  def mount(params, socket) do
    {:ok,
     assign(
       socket,
       pid: params.pid,
       chord: params.chord,
       index: params.index,
       string: params.string,
       fret: params.fret,
       freq: params.freq
     )}
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

    {
      :noreply,
      socket
      |> assign(:chords, chords)
    }
  end

  def fret_classes(string, fret, playing, freq) do
    [
      if Enum.at(playing, string) == fret do
        "played"
      else
        "unplayed"
      end,
      if fret == 0 do
        "first"
      else
        nil
      end,
      if fret == 17 do
        "last"
      else
        nil
      end,
      if string == 0 do
        "bottom"
      else
        nil
      end,
      if string == 5 do
        "top"
      else
        nil
      end,
      if freq > 0 do
        "playable"
      else
        nil
      end
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  def fret_color(string, fret, freq) do
    colorizer =
      Cubehelix.colorizer(
        2.869878683553023,
        -0.03712681223962111,
        3,
        0.5
      )

    {r, g, b} = colorizer.(Enum.max([Enum.min([0.9, :math.pow(1 - freq, 2)]), 0.0]))
    "rgb(#{256 * r}, #{256 * g}, #{256 * b})"
  end

  def fret_background_color(string, fret, freq) do
    colorizer =
      Cubehelix.colorizer(
        2.869878683553023,
        -0.03712681223962111,
        3,
        0.5
      )

    {r, g, b} = colorizer.(Enum.max([Enum.min([0.9, :math.pow(1 - freq, 2)]), 0.1]))
    "rgba(#{256 * r}, #{256 * g}, #{256 * b}, 0.125)"
  end

  def root_options do
    [
      "C",
      "C#/Db",
      "D",
      "D#/Eb",
      "E",
      "F",
      "F#/Gb",
      "G",
      "G#/Ab",
      "A",
      "A#/Bb",
      "B"
    ]
  end

  def quality_options do
    [
      "maj7",
      "m7",
      "m7b5",
      "7"
    ]
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
