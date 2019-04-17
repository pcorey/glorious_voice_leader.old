defmodule Chord.Type.Strings do
  @behaviour Ecto.Type
  def type, do: :integer

  @doc """
  Validate that the given value is a number of strings.
  ## Examples
  iex> Chord.Type.Strings.cast(6)
  {:ok, 6}
  iex> Chord.Type.Strings.cast(0)
  :error
  iex> Chord.Type.Strings.cast(-1)
  :error
  """
  def cast(strings) when is_integer(strings) and strings > 0 do
    {:ok, strings}
  end

  def cast(_), do: :error

  # converts a value to our ecto type
  def load(strings), do: {:ok, strings}

  # converts our ecto type to a value
  def dump(strings), do: {:ok, strings}
end
