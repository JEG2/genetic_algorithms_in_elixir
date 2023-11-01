defmodule PrimordialSoup.Statistics do
  use GenServer

  def insert(generation, statistics) do
    :ets.insert(__MODULE__, {generation, statistics})
  end

  def lookup(generation) do
    __MODULE__
    |> :ets.lookup(generation)
    |> hd()
    |> elem(1)
  end

  def dump() do
    :ets.tab2list(__MODULE__)
  end

  def calculate_statistics(population) do
    scores = Enum.map(population, & &1.fitness)
    {min, max} = Enum.min_max(scores)

    %{
      min_fitness: min,
      max_fitness: max,
      mean_fitness: Enum.sum(scores) / Enum.count(scores)
    }
  end

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def init([]) do
    :ets.new(__MODULE__, ~w[set public named_table]a)
    {:ok, nil}
  end
end
