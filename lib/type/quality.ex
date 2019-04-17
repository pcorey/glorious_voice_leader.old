defmodule Chord.Type.Quality do
  @behaviour Ecto.Type
  def type, do: {:array, :integer}

  @doc """
  Validate that the given value is a chord quality.
  ## Examples
  iex> Chord.Type.Quality.cast([4, 3, 4, 1])
  {:ok, [4, 3, 4, 1]}
  iex> Chord.Type.Quality.cast([4, 4, 4, 4])
  :error
  iex> Chord.Type.Quality.cast(0)
  :error
  """
  def cast(nil) do
    {:ok, nil}
  end

  def cast(quality) when is_list(quality) do
    all_integers = Enum.all?(quality, &is_integer/1)
    all_positive = Enum.all?(quality, &(&1 > 0))
    fills_octave = Enum.sum(quality) == 12

    if all_integers and all_positive and fills_octave do
      {:ok, quality}
    else
      :error
    end
  end

  def cast(_), do: :error

  # converts a value to our ecto type
  def load(quality), do: {:ok, quality}

  # converts our ecto type to a value
  def dump(quality), do: {:ok, quality}
end
