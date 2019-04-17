defmodule Chord.Type.Chord do
  @behaviour Ecto.Type
  def type, do: {:array, :integer}

  @doc """
  Validate that the given value is a chord.
  ## Examples
  iex> Chord.Type.Chord.cast([nil, 3, 2, 0, 1, nil])
  {:ok, [nil, 3, 2, 0, 1, nil]}
  iex> Chord.Type.Chord.cast([-1, 0, 1, 2, 3, 4])
  :error
  iex> Chord.Type.Chord.cast(0)
  :error
  """
  def cast(chord) when is_list(chord) do
    all_nil_or_integers = Enum.all?(chord, &(is_nil(&1) or is_integer(&1)))
    all_nil_or_positive = Enum.all?(chord, &(is_nil(&1) or &1 >= 0))

    if all_nil_or_integers and all_nil_or_positive do
      {:ok, chord}
    else
      :error
    end
  end

  def cast(_), do: :error

  # converts a value to our ecto type
  def load(chord), do: {:ok, chord}

  # converts our ecto type to a value
  def dump(chord), do: {:ok, chord}
end
