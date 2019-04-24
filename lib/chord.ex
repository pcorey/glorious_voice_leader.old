defmodule Chord do
  alias Chord.Type
  alias Ecto.Changeset

  use Ecto.Schema

  schema "chords" do
    field(:chord, Type.Chord, default: [nil, nil, nil, nil, nil, nil])
    field(:fretboard, Type.Fretboard, default: Fretboard.new(6, 18))
    field(:gaps, Type.Gaps, default: nil)
    field(:quality, Type.Quality, default: nil)
    field(:root, Type.Root, default: 0)
    field(:strings, Type.Strings, default: 6)
    field(:tuning, Type.Tuning, default: [40, 45, 50, 55, 59, 64])
  end

  def changeset(chord, params \\ %{}) do
    chord
    |> Changeset.cast(params, [
      :chord,
      :fretboard,
      :gaps,
      :quality,
      :root,
      :strings,
      :tuning
    ])
  end

  def to_notes(chord) do
    chord
    |> Map.fetch!(:chord)
    |> Enum.zip(chord.tuning)
    |> Enum.reject(fn
      {nil, _} -> true
      _ -> false
    end)
    |> Enum.map(fn {fret, open} -> fret + open end)
  end
end
