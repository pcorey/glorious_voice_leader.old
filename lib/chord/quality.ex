defmodule Chord.Quality do
  @quality_options %{
    "maj7" => [4, 3, 4, 1],
    "m7" => [3, 4, 3, 2],
    "m7b5" => [3, 3, 4, 2],
    "7" => [4, 3, 3, 2]
  }

  def options do
    @quality_options
  end

  def name(value) do
    @quality_options
    |> Map.to_list()
    |> Enum.find(fn
      {_, quality} -> quality == value
      _ -> false
    end)
    |> elem(0)
  end
end
