defmodule Chord.Heatmap do
  def generate(root, quality, playing, previous \\ [nil, nil, nil, nil, nil, nil]) do
    Chord.Table.lookup(root)
    |> filter_on_qualities([quality])
    |> filter_on_playing(playing)
    # |> filter_on_bass(bass)
    # |> filter_on_melody(melody)
    |> sort_by_previous(previous)
    |> add_possibilities(previous)
  end

  defp filter_on_playing(chords, playing) do
    playing =
      playing
      |> Enum.with_index()
      |> Enum.reject(fn
        {nil, _} -> true
        _ -> false
      end)

    chords
    |> Enum.filter(fn %{chord: chord} ->
      chord =
        chord
        |> Enum.with_index()
        |> Enum.reject(fn
          {nil, _} -> true
          _ -> false
        end)

      playing -- chord == []
    end)
  end

  defp filter_on_qualities(chords, qualities) do
    chords
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

  defp sort_by_previous(chords, [nil, nil, nil, nil, nil, nil]) do
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

  defp recursive_sum(list_a, list_b) when is_list(list_a) and is_list(list_b) do
    Enum.zip(list_a, list_b)
    |> Enum.map(fn {a, b} ->
      recursive_sum(a, b)
    end)
  end

  defp recursive_sum(a, b) do
    a + b
  end

  defp add_possibilities([], _) do
    Fretboard.new(6, 18, 0)
  end

  defp add_possibilities(possibilities, previous) do
    possibilities =
      possibilities
      |> Enum.map(&Fretboard.from_chord(&1.chord))
      |> Enum.with_index()
      |> Enum.map(fn {fretboard, index} ->
        for string <- fretboard do
          for count <- string do
            if previous == [nil, nil, nil, nil, nil, nil] do
              count
            else
              count / (index + 1)
            end
          end
        end
      end)
      |> Enum.reduce(fn a, b ->
        recursive_sum(a, b)
      end)

    max =
      possibilities
      |> List.flatten()
      |> Enum.max()

    possibilities
    |> Enum.with_index()
    |> Enum.map(fn {strings, index} ->
      strings
      |> Enum.map(fn count ->
        count / max
      end)
    end)
  end
end
