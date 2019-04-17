defmodule Chord.Type.Gaps do
  @behaviour Ecto.Type
  def type, do: {:array, :integer}

  @doc """
  Validate that the given value is a chord's V-system gaps.
  For more information:
  https://www.tedgreene.com/images/lessons/v_system/11_Method_2-Further_Insights.pdf
  ## Examples
  iex> Chord.Type.Gaps.cast(nil)
  {:ok, nil}
  iex> Chord.Type.Gaps.cast([0, 0, 0])
  {:ok, [0, 0, 0]}
  iex> Chord.Type.Gaps.cast([5, 5, 5])
  :error
  iex> Chord.Type.Gaps.cast(0)
  :error
  """
  def cast(nil) do
    {:ok, nil}
  end

  def cast(gaps)
      when gaps in [
             [0, 0, 0],
             [1, 0, 1],
             [0, 1, 2],
             [2, 1, 0],
             [1, 2, 1],
             [4, 0, 0],
             [5, 0, 1],
             [2, 2, 2],
             [1, 0, 5],
             [1, 4, 1],
             [2, 1, 4],
             [4, 1, 2],
             [0, 4, 0],
             [0, 0, 4]
           ] do
    {:ok, gaps}
  end

  def cast(_), do: :error

  # converts a value to our ecto type
  def load(gaps), do: {:ok, gaps}

  # converts our ecto type to a value
  def dump(gaps), do: {:ok, gaps}
end
