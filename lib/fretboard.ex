defmodule Fretboard do
  def to_string(fretboard) do
    for {frets, s} <- Enum.with_index(fretboard) do
      for {fret, f} <- Enum.with_index(frets) do
        cond do
          s == 0 ->
            cond do
              f == 0 ->
                case fret do
                  true -> "○"
                  false -> "┌"
                end

              f == length(List.first(fretboard)) - 1 ->
                case fret do
                  true -> "─●─┐"
                  false -> "───┐"
                end

              true ->
                case fret do
                  true -> "─●─┬"
                  false -> "───┬"
                end
            end

          s == length(fretboard) - 1 ->
            cond do
              f == 0 ->
                case fret do
                  true -> "○"
                  false -> "└"
                end

              f == length(List.first(fretboard)) - 1 ->
                case fret do
                  true -> "─●─┘"
                  false -> "───┘"
                end

              true ->
                case fret do
                  true -> "─●─┴"
                  false -> "───┴"
                end
            end

          true ->
            cond do
              f == 0 ->
                case fret do
                  true -> "○"
                  false -> "├"
                end

              f == length(List.first(fretboard)) - 1 ->
                case fret do
                  true -> "─●─┤"
                  false -> "───┤"
                end

              true ->
                case fret do
                  true -> "─●─┼"
                  false -> "───┼"
                end
            end
        end
      end ++ "\n"
    end
  end

  def from_chord(chord, tuning) do
    chord
    |> Enum.with_index()
    |> Enum.reduce(Fretboard.new(length(tuning), 18, 0), fn
      {nil, _string}, fretboard ->
        fretboard

      {fret, string}, fretboard ->
        fretboard
        |> List.replace_at(
          string,
          fretboard
          |> Enum.at(string)
          |> List.replace_at(
            fret,
            fretboard
            |> Enum.at(string)
            |> Enum.at(fret)
            |> Kernel.+(1)
          )
        )
    end)
  end

  def new(strings, frets, default \\ false) do
    default
    |> List.duplicate(frets)
    |> List.duplicate(strings)
  end
end
