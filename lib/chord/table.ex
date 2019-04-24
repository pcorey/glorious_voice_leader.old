defmodule Chord.Table do
  require Ecto.Query

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{generated: false}}
  end

  def insert(data) do
    GenServer.call(__MODULE__, {:insert, data})
  end

  def lookup(root) do
    GenServer.call(__MODULE__, {:lookup, root})
  end

  def generated() do
    GenServer.call(__MODULE__, :generated)
  end

  def handle_call({:insert, data}, _from, state) do
    result = Chord.Repo.insert(data)
    {:reply, result, state}
  end

  def handle_call({:lookup, root}, _from, state) do
    result = Chord |> Ecto.Query.where(root: ^root) |> Chord.Repo.all()
    {:reply, result, state}
  end

  def handle_cast({:generate, from}, state = %{generated: true}) do
    send(from, :generated)
    {:noreply, state}
  end

  def handle_call(:generated, _from, state) do
    result = state.generated
    {:reply, result, state}
  end

  def handle_cast({:generate, from}, state) do
    Chords.generate()
    |> Enum.map(&Chord.Repo.insert/1)

    IO.puts("All voicings generated.")

    send(from, :generated)

    {:noreply, %{state | generated: true}}
  end
end
