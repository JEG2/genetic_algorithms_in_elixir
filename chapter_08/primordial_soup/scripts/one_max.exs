defmodule OneMax do
  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine

  @impl GeneticLine
  def generate do
    genes =
      Stream.repeatedly(fn -> :rand.uniform(2) - 1 end)
      |> Enum.take(10)

    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome) do
    IO.inspect(chromosome)

    IO.gets("Rate from 1 to 10:  ")
    |> String.trim()
    |> String.to_integer()
  end

  @impl GeneticLine
  def terminate?([best | _rest], _generation) do
    best.fitness == best.size
  end
end

OneMax
|> PrimordialSoup.evolve(population_size: 10)
|> IO.inspect()
