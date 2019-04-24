defmodule Chord.Quality do
  # https://www.tedgreene.com/images/lessons/v_system/14_The_43_Four-Note_Qualities.pdf
  @quality_options %{
    # # "Weird" qualities:
    # "???" => [1, 1, 9, 1],
    # "???" => [1, 2, 8, 1],
    # "???" => [1, 3, 7, 1],
    # "???" => [1, 4, 6, 1],
    # "???" => [1, 5, 5, 1],
    # "???" => [1, 6, 4, 1],
    # "???" => [1, 7, 3, 1],
    # "???" => [1, 8, 2, 1],
    # "Normal" qualities:
    # "m∆9 no 5" => [2, 1, 8, 1],
    # "∆9 no 5" => [2, 2, 7, 1],
    # "7/11 no R" => [2, 3, 6, 1],
    # "7/6 no 5" => [4, 5, 1, 2],
    # "∆9 no 3" => [2, 5, 4, 1],
    # "(7)#9b5 no b7" => [3, 1, 2, 6],
    # "7/6 no 3" => [7, 2, 1, 2],
    # "11b9 no 5, b7" => [1, 3, 1, 7],
    # "7#11 no 3" => [6, 1, 3, 2],
    # "7#9 no R" => [3, 3, 5, 1],
    # "m∆7" => [3, 4, 4, 1],
    # "with 3 and b3" => [3, 5, 3, 1],
    # "7b9 no 5" => [1, 3, 6, 2],
    # "∆7#11 no 3" => [6, 1, 4, 1],
    # "13 no R, 5" => [4, 2, 5, 1],
    "∆7" => [4, 3, 4, 1],
    # "m∆9 no R" => [4, 4, 3, 1],
    # "m/9" => [2, 1, 4, 5],
    # "13#9 no R, 5" => [5, 1, 5, 1],
    # "7/11 no 5" => [4, 1, 5, 2],
    # "11b9 no R, 5" => [5, 3, 3, 1],
    # "11 no R, 5" => [5, 4, 2, 1],
    # "7#9 no 5" => [3, 1, 6, 2],
    # "m6/9 no 5" => [2, 1, 6, 3],
    # "m9 no 5" => [2, 1, 7, 2],
    # "9 no 5" => [2, 2, 6, 2],
    # "/9" => [2, 2, 3, 5],
    # "7+" => [4, 4, 2, 2],
    # "6/9 no 5" => [2, 2, 5, 3],
    # "6/9 no R" => [3, 2, 5, 2],
    "m7b5" => [3, 3, 4, 2],
    "m7" => [3, 4, 3, 2],
    # "7b5" => [4, 2, 4, 2],
    "7" => [4, 3, 3, 2]
    # "°7" => [3, 3, 3, 3]
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

  def names do
    Map.keys(@quality_options)
  end

  def value(name) do
    Map.get(@quality_options, name)
  end

  def values() do
    Map.values(@quality_options)
  end
end
