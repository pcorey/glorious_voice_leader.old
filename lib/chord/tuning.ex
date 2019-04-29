defmodule Chord.Tuning do
  @tuning_options %{
    "E A D G B E" => [40, 45, 50, 55, 59, 64],
    "D G B E" => [50, 55, 59, 64]
  }

  def options do
    @tuning_options
  end

  def name(value) do
    @tuning_options
    |> Map.to_list()
    |> Enum.find(fn
      {_, tuning} -> tuning == value
      _ -> false
    end)
    |> elem(0)
  end

  def names do
    Map.keys(@tuning_options)
  end

  def value(name) do
    Map.get(@tuning_options, name)
  end

  def values() do
    Map.values(@tuning_options)
  end
end
