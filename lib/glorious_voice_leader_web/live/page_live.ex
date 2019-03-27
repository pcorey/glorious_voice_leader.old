defmodule GVLWeb.PageLive do
  use Phoenix.LiveView

  def render(assigns) do
    GVLWeb.PageView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    {:ok,
     assign(
       socket,
       chords: [
         %{
           root: 0,
           quality: [4, 3, 4, 2],
           possibilities:
             Chord.Table.lookup(0)
             |> IO.inspect()
             |> filter_on_qualities([[4, 3, 4, 2]])
             # |> filter_on_bass(bass)
             # |> filter_on_melody(melody)
             |> sort_by_previous([])
             |> IO.inspect(label: "Possibilities")
         }
       ]
     )}
  end

  defp filter_on_qualities(chords, qualities) do
    chords
    |> Enum.map(&elem(&1, 1))
    |> Enum.filter(fn %{quality: quality} -> Enum.any?(qualities, &(&1 == quality)) end)
  end

  defp filter_on_bass(chords, nil) do
    chords
  end

  defp filter_on_bass(chords, bass) do
    chords
    |> Enum.filter(fn chord ->
      bass ==
        chord
        |> Chord.to_notes()
        |> Enum.sort()
        |> List.first()
    end)
  end

  defp filter_on_melody(chords, nil) do
    chords
  end

  defp filter_on_melody(chords, melody) do
    chords
    |> Enum.filter(fn chord ->
      melody ==
        chord
        |> Chord.to_notes()
        |> Enum.sort()
        |> List.last()
    end)
  end

  defp sort_by_previous(chords, []) do
    chords
  end

  defp sort_by_previous(chords, previous) do
    previous_fingerings = Chord.Fingering.fingerings(previous)

    chords
    |> Enum.map(
      &{&1
       |> Map.fetch!(:chord)
       |> Chord.Distance.Semitone.distance(previous),
       &1
       |> Map.fetch!(:chord)
       |> Chord.Fingering.fingerings()
       |> (fn fingerings ->
             for(
               fingering_a <- previous_fingerings,
               fingering_b <- fingerings,
               do: Chord.Distance.Fingering.distance(fingering_a, fingering_b, [])
             )
             |> Enum.min()
           end).(), &1}
    )
    |> Enum.sort()
    |> Enum.map(&elem(&1, 2))
  end
end
