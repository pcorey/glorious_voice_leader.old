defmodule Chords do
  @gap_sets_and_string_sets [
    # V-1:
    {[0, 0, 0],
     [
       [false, true, true, true, true, false],
       [false, false, true, true, true, true],
       [true, true, true, true, false, false]
     ]},
    # V-2:
    {[1, 0, 1],
     [
       [false, false, true, true, true, true],
       [false, true, true, true, true, false],
       [true, true, true, true, false, false]
     ]},
    # V-3:
    {[0, 1, 2],
     [
       [false, true, true, true, false, true],
       [true, true, true, false, true, false]
     ]},
    # V-4:
    {[2, 1, 0],
     [
       [true, false, true, true, true, false],
       [false, true, false, true, true, true]
     ]},
    # V-5:
    {[1, 2, 1],
     [
       [false, true, true, false, true, true],
       [true, true, false, true, true, false]
     ]},
    # V-6:
    {[4, 0, 0],
     [
       [true, false, false, true, true, true]
     ]},
    # V-7:
    {[5, 0, 1],
     [
       [true, false, false, true, true, true]
     ]},
    # V-8:
    {[2, 2, 2],
     [
       [true, false, true, false, true, true],
       [true, false, true, true, false, true],
       [true, true, false, true, false, true],
       [true, true, false, false, true, true]
     ]},
    # V-9:
    {[1, 0, 5],
     [
       [true, true, true, false, false, true]
     ]},
    # V-10:
    {[1, 4, 1],
     [
       [true, true, false, false, true, true]
     ]},
    # V-11:
    {[2, 1, 4],
     [
       [true, false, true, true, false, true],
       [true, true, true, false, false, true],
       [true, true, false, true, false, true]
     ]},
    # V-12:
    {[4, 1, 2],
     [
       [true, false, false, true, true, true],
       [true, false, true, true, false, true],
       [true, false, true, false, true, true]
     ]},
    # V-13:
    {[0, 4, 0],
     [
       [true, true, false, false, true, true],
       [true, true, false, true, true, false],
       [false, true, true, false, true, true]
     ]},
    # V-14:
    {[0, 0, 4],
     [
       [true, true, true, false, false, true],
       [true, true, true, false, true, false],
       [false, true, true, true, false, true]
     ]}
  ]

  @frets 18

  def generate(roots \\ Chord.Root.values(), qualities \\ Chord.Qualities.values(), tuning) do
    for root <- roots,
        quality <- qualities,
        {gaps, string_sets} <- @gap_sets_and_string_sets,
        string_mask <- string_sets do
      strings =
        string_mask
        |> Enum.zip(tuning)
        |> Enum.map(fn
          {true, open} -> open
          {false, _} -> nil
        end)

      voicings(root, quality, gaps, strings, @frets)
      |> Enum.map(
        &%Chord{
          chord: &1,
          # fretboard: Fretboard.from_chord(&1),
          # gaps: gaps,
          quality: quality,
          root: root
          # strings: strings,
          # tuning: @tuning
        }
      )
    end
    |> Enum.reduce(&Kernel.++/2)
  end

  defp arpeggiate(root, quality) do
    [rem(root, 12)]
    |> Stream.concat(Stream.cycle(quality))
    |> Stream.scan(&Kernel.+/2)
  end

  defp mask(arpeggio, gaps) do
    gap_mask =
      gaps
      |> Enum.map(&([true] ++ List.duplicate(false, &1)))
      |> Kernel.++([true])
      |> List.flatten()

    arpeggio
    |> Stream.zip(Stream.cycle(gap_mask))
    |> Stream.filter(&elem(&1, 1))
    |> Stream.map(&elem(&1, 0))
    |> Enum.take(length(gaps) + 1)
  end

  defp fit_to_strings(notes, strings) do
    strings
    |> Enum.reduce({notes, []}, fn
      nil, {notes, chord} ->
        {notes, chord ++ [nil]}

      open, {[note | notes], chord} ->
        {notes, chord ++ [note - open]}
    end)
    |> elem(1)
  end

  defp build_chord({arpeggio, drop}, gaps, strings) do
    arpeggio
    |> Stream.drop(drop)
    |> mask(gaps)
    |> fit_to_strings(strings)
  end

  defp below_nut(chord) do
    0 >
      chord
      |> Enum.reject(&is_nil/1)
      |> Enum.min()
  end

  defp within_neck(chord, frets) do
    frets >
      chord
      |> Enum.reject(&is_nil/1)
      |> Enum.max()
  end

  defp voicings(root, quality, gaps, strings, frets) do
    [arpeggiate(root, quality)]
    |> Stream.cycle()
    |> Stream.with_index()
    |> Stream.map(&build_chord(&1, gaps, strings))
    |> Stream.drop_while(&below_nut/1)
    |> Stream.take_while(&within_neck(&1, frets))
    |> Enum.to_list()
  end
end
