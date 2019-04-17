defmodule Chord.Input do
  use Ecto.Schema

  embedded_schema do
    field(:root)
    field(:quality)
  end

  def changeset(chord_input, params \\ %{}) do
    Ecto.Changeset.cast(chord_input, params, [:root, :quality])
  end
end
