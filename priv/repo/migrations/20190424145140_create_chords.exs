defmodule Chord.Repo.Migrations.CreateChords do
  use Ecto.Migration

  def change do
    create table(:chords) do
      add(:chord, {:array, :integer})
      add(:fretboard, {:array, {:array, :integer}})
      add(:gaps, {:array, :integer})
      add(:quality, {:array, :integer})
      add(:root, :integer)
      add(:strings, :integer)
      add(:tuning, {:array, :integer})
    end

    create(unique_index(:chords, [:chord]))
  end
end
