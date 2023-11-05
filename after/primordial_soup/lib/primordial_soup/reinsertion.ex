defmodule PrimordialSoup.Reinsertion do
  @moduledoc false

  def pure(parents, offspring, rest, options) do
    population_size = Keyword.fetch!(options, :population_size)

    [offspring, rest, parents]
    |> Stream.concat()
    |> Enum.take(population_size)
  end

  def elitist(parents, offspring, rest, options) do
    population_size = Keyword.fetch!(options, :population_size)
    survivors = Enum.sort_by(parents ++ rest, & &1.fitness, :desc)

    [offspring, survivors]
    |> Stream.concat()
    |> Enum.take(population_size)
  end

  def uniform(parents, offspring, rest, options) do
    population_size = Keyword.fetch!(options, :population_size)

    survivors =
      Enum.take_random(
        parents ++ rest,
        population_size - length(offspring)
      )

    offspring ++ survivors
  end
end
