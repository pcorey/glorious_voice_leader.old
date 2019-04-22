defmodule GVLWeb.StringLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="string">
      <%= for {freq, fret} <- Enum.with_index(@frets) do %>
        <%= live_render(@socket, GVLWeb.FretLive, session: %{
          index: @index,
          pid: @pid,
          chord: @chord,
          frets: @frets,
          string: @string,
          fret: fret,
          freq: freq
        }, child_id: fret) %>
      <%= end %>
    </div>
    """
  end

  def mount(params, socket) do
    {:ok,
     assign(
       socket,
       pid: params.pid,
       chord: params.chord,
       index: params.index,
       frets: params.frets,
       string: params.string
     )}
  end

  def handle_event("click", _, socket) do
    {:noreply, socket}
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
