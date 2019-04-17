defmodule Chord.Type.Tuning do
  @behaviour Ecto.Type
  def type, do: {:array, :integer}

  @doc """
  Validate that the given value is a chord tuning.
  ## Examples
  iex> Chord.Type.Tuning.cast([40, 45, 50, 55, 59, 64])
  {:ok, [40, 45, 50, 55, 59, 64]}
  iex> Chord.Type.Tuning.cast([-1, 2, 3, 4, 5, 6])
  :error
  iex> Chord.Type.Tuning.cast(0)
  :error
  """
  def cast(tuning) when is_list(tuning) do
    all_integers = Enum.all?(tuning, &is_integer/1)
    all_positive = Enum.all?(tuning, &(&1 > 0))

    if all_integers and all_positive do
      {:ok, tuning}
    else
      :error
    end
  end

  def cast(_), do: :error

  # converts a value to our ecto type
  def load(tuning), do: {:ok, tuning}

  # converts our ecto type to a value
  def dump(tuning), do: {:ok, tuning}
end
