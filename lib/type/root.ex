defmodule Chord.Type.Root do
  @behaviour Ecto.Type
  def type, do: :integer

  @doc """
  Validate that the given value is a chord root.
  ## Examples
  iex> Chord.Type.Root.cast(0)
  {:ok, 0}
  iex> Chord.Type.Root.cast(12)
  :error
  iex> Chord.Type.Root.cast(-1)
  :error
  """
  def cast(root) when is_integer(root) and root >= 0 and root <= 11 do
    {:ok, root}
  end

  def cast(_), do: :error

  # converts a value to our ecto type
  def load(root), do: {:ok, root}

  # converts our ecto type to a value
  def dump(root), do: {:ok, root}
end
