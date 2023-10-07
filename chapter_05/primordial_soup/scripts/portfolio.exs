defmodule Portfolio do
  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine

  @impl GeneticLine
  def generate do
    genes =
      Stream.repeatedly(fn -> {Enum.random(1..10), Enum.random(1..10)} end)
      |> Enum.take(10)

    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome) do
    chromosome.genes
    |> Enum.map(fn {roi, risk} -> 2 * roi - risk end)
    |> Enum.sum()
  end

  @impl GeneticLine
  def terminate?([best | _rest], _generation) do
    best.fitness > 180
  end
end

Portfolio
|> PrimordialSoup.evolve(show_progress: true)
|> IO.inspect()
