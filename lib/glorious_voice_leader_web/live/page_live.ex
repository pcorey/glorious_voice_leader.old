defmodule GVLWeb.PageLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  def render(assigns = %{loading: true}) do
    ~L"""
    <div class="loading">
    <p>Generating chords...</p>
    </div>
    """
  end

  def render(assigns) do
    ~L"""
    <div class="page" >
    <div class="header">
    <%= if is_binary(@title) do %>
    <h1><%= @title %></h1>
    <%= end %>
    <p><strong>Glorious Voice Leader</strong> suggests guitar chord voicings for a given chord type based on the voicing that came before it. Glorious Voice Leader tries to optimize for voice leading between chords, while also balancing playability.</p>
    </div>
    <%= for {chord, index} <- Enum.with_index(@chords) do %>
    <div class="chord">
    <%= f = form_for %Plug.Conn{}, "#", [phx_change: :validate] %>
    <div class="selects">
      <%= hidden_input f, :index, value: index %>
      <%= select f, :root_name, Chord.Root.names(), value: chord.root_name %>
      <%= select f, :quality_name, Chord.Quality.names() |> Enum.sort(), value: chord.quality_name %>
    </div>
    <div class="buttons">
      <button phx-click="clear_fretboard" phx-value="<%= index %>">clear</button>
      <%= if index != 0 do %>
        <button phx-click="remove_fretboard" phx-value="<%= index %>">remove</button>
      <%= end %>
      <button onclick="play(<%= index %>, <%= inspect(midi(chord.playing), charlists: :as_lists) %>)" type="button">play</button>
      <script>
        function play(index, playing) {
          console.log(index, playing);
          let notes = playing.map(midi => new Tone.Frequency(midi, "midi"))
          synth.triggerAttackRelease(notes, 0.25, undefined, 0.25);
        }
      </script>
    </div>
    </form>

    <div class="fretboard">
    <%= for {frets, string} <- Enum.with_index(chord.heatmap) |> Enum.reverse() do %>
      <div class="string">
      <%= for {freq, fret} <- Enum.with_index(frets) do %>
      <div class='fret <%= fret_classes(string, fret, chord.playing, freq) %>'
      style='color: <%= fret_color(string, fret, freq) %>; background-color: <%= fret_background_color(string, fret, freq) %>'
      phx-click="click_fret" phx-value=<%= {index, string, fret, if Enum.at(chord.playing, string) == fret do nil else fret end} |> :erlang.term_to_binary() |> Base.encode64() %>
      ></div>
      <%= end %>
      </div>
    <%= end %>
    <div class="string marker">
    <div class="marker">&nbsp;</div>
    <div class="marker">&nbsp;&nbsp;&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;&nbsp;&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;3&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;&nbsp;&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;5&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;&nbsp;&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;7&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;&nbsp;&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;9&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;&nbsp;&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;&nbsp;&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;12&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;&nbsp;&nbsp;&nbsp;</div>
    <div class="marker">&nbsp;15&nbsp;&nbsp;</div>
    </div>
    </div>
    </div>
    <%= end %>
    <button class="add-new-chord" phx-click="add_new_chord">+ Add New Chord</button>

    <p>Glorious Voice Leader is heavily inspired by <a href="https://amzn.to/2Ince4p">the works of the amazing guitarist and educator, Ted Greene</a>. All hail, Glorious Voice Leader!</p>
    <p>Use <a href="/?chords=<%= @token %>">this link</a> to share your chord progression.</p>
    </div>
    """
  end

  def mount(params, socket) do
    if connected?(socket), do: send(self(), :generate)

    {:ok,
     assign(
       socket,
       loading: true,
       params: params
     )}
  end

  defp initial_chords(nil) do
    [
      %{
        heatmap: Chord.Heatmap.generate(0, [4, 3, 4, 1], [nil, nil, nil, nil, nil, nil]),
        playing: [nil, nil, nil, nil, nil, nil],
        quality: [4, 3, 4, 1],
        quality_name: "∆7",
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
        Chord.Root.options()
        |> Map.to_list()
        |> Enum.find(fn
          {_, root} -> root == chord.root
          _ -> false
        end)
        |> elem(0)
      )
      |> Map.put_new(
        :quality_name,
        Chord.Quality.options()
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
    root = Chord.Root.value(root_name)
    quality_name = input["quality_name"]
    quality = Chord.Quality.value(quality_name)

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
            quality_name: "∆7",
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

    {:noreply,
     socket
     |> assign(:chords, chords)
     |> assign(:token, update_token(chords))}
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

    {:noreply,
     socket
     |> assign(:chords, chords)
     |> assign(:token, update_token(chords))}
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

  def midi(playing) do
    playing
    |> Enum.zip([40, 45, 50, 55, 59, 64])
    |> Enum.reject(fn
      {nil, _} -> true
      _ -> false
    end)
    |> Enum.map(fn {fret, open} -> fret + open end)
  end

  def handle_info(:generated, socket) do
    chords = initial_chords(Map.get(socket.assigns.params, "chords"))

    {:noreply,
     assign(
       socket,
       title: Map.get(socket.assigns.params, "title"),
       token: update_token(chords),
       loading: false,
       chords: chords
     )}
  end

  def handle_info(:generate, socket) do
    GenServer.cast(Chord.Table, {:generate, self()})
    {:noreply, socket}
  end
end
