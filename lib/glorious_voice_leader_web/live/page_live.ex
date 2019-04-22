defmodule GVLWeb.PageLive do
  use Phoenix.LiveView

  def render(assigns) do
    IO.puts("rerendering page")

    ~L"""
    <div class="page" >

      <div class="header">

        <%= if is_binary(@title) do %>
          <h1><%= @title %></h1>
        <%= end %>

        <p><strong>Glorious Voice Leader</strong> suggests guitar chord voicings for a given chord type based on the voicing that came before it. Glorious Voice Leader tries to optimize for voice leading between chords, while also balancing playability.</p>

      </div>

      <%= for {chord, index} <- Enum.with_index(@chords) do %>
        <%= live_render(@socket, GVLWeb.ChordLive, session: %{
          pid: @pid,
          chord: chord,
          index: index,
          chords: @chords,
          root_name: chord.root_name,
          quality_name: chord.quality_name
        }, child_id: index) %>
      <%= end %>

      <%= live_render(@socket, GVLWeb.AddChordLive, session: %{
        chords: @chords,
        pid: @pid
      }, child_id: @chords |> inspect) %>

      <p>Glorious Voice Leader is heavily inspired by <a href="https://amzn.to/2Ince4p">the works of the amazing guitarist and educator, Ted Greene</a>. All hail, Glorious Voice Leader!</p>
      <p>Use <a href="/?chords=<%= @token %>">this link</a> to share your chord progression.</p>

    </div>
    """
  end

  def mount(params, socket) do
    chords = initial_chords(Map.get(params, "chords"))

    {:ok,
     assign(
       socket,
       title: Map.get(params, "title"),
       token: update_token(chords),
       chords: chords,
       pid: self()
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
        Chord.Root.name(chord.root)
      )
      |> Map.put_new(
        :quality_name,
        Chord.Quality.name(chord.quality)
      )
      |> Map.put_new(
        :heatmap,
        Chord.Heatmap.generate(chord.root, chord.quality, chord.playing, previous)
      )
    end)
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

  def handle_info({:update_chords, chords}, socket) do
    IO.puts("handling info")

    {:noreply,
     socket
     |> assign(:chords, chords)
     |> assign(:token, update_token(chords))}
  end
end
