defmodule Chord.Root do
  @root_options %{
    "C" => 0,
    "C#/Db" => 1,
    "D" => 2,
    "D#/Eb" => 3,
    "E" => 4,
    "F" => 5,
    "F#/Gb" => 6,
    "G" => 7,
    "G#/Ab" => 8,
    "A" => 9,
    "A#/Bb" => 10,
    "B" => 11
  }

  def options do
    @root_options
  end

  def name(value) do
    @root_options
    |> Map.to_list()
    |> Enum.find(fn
      {_, root} -> root == value
      _ -> false
    end)
    |> elem(0)
  end
end
