defmodule Chord.Type.Fretboard do
  @behaviour Ecto.Type
  def type, do: {:array, {:array, :boolean}}

  @doc """
  Validate that the given value is a fretboard.
  ## Examples
  iex> Chord.Type.Fretboard.cast([
    [false, false, false, false, false],
    [false, true, false, false, false],
    [true, false, false, false, false],
    [false, false, true, false, false],
    [false, false, false, true, false],
    [false, false, false, false, false],
  ])
  {:ok, [
    [false, false, false, false, false],
    [false, true, false, false, false],
    [true, false, false, false, false],
    [false, false, true, false, false],
    [false, false, false, true, false],
    [false, false, false, false, false],
  ]}
  iex> Chord.Type.Fretboard.cast(0)
  :error
  """
  def cast(fretboard) when is_list(fretboard) do
    all_same_length =
      Enum.reduce(fretboard, {true, nil}, fn
        string, {true, nil} ->
          {true, length(string)}

        string, {same_length, previous_length} ->
          {same_length and previous_length == length(string), length(string)}
      end)

    all_booleans =
      fretboard
      |> Enum.map(fn string ->
        Enum.all?(string, &is_boolean/1)
      end)
      |> Enum.all?(&is_boolean/1)

    if all_same_length and all_booleans do
      {:ok, fretboard}
    else
      :error
    end
  end

  def cast(_), do: :error

  # converts a value to our ecto type
  def load(fretboard), do: {:ok, fretboard}

  # converts our ecto type to a value
  def dump(fretboard), do: {:ok, fretboard}
end
