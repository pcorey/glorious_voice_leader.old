defmodule Chord.Table do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    table = :ets.new(:chords, [:protected, :bag])

    {:ok, %{table: table, generated: false}}
  end

  def insert(data) do
    GenServer.call(__MODULE__, {:insert, data})
  end

  def lookup(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  def table() do
    GenServer.call(__MODULE__, {:table})
  end

  def generated() do
    GenServer.call(__MODULE__, :generated)
  end

  def handle_call({:insert, data}, _from, state) do
    result = :ets.insert(state.table, data)
    {:reply, result, state}
  end

  def handle_call({:lookup, key}, _from, state) do
    result = :ets.lookup(state.table, key)
    {:reply, result, state}
  end

  def handle_call({:table}, _from, state) do
    {:reply, state.table, state}
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
    |> Enum.map(&:ets.insert(state.table, {&1.root, &1}))

    IO.puts("All voicings generated.")

    send(from, :generated)

    {:noreply, %{state | generated: true}}
  end
end
