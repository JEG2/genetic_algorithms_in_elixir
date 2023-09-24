defmodule OneMax do
  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine

  @impl GeneticLine
  def generate do
    genes =
      Stream.repeatedly(fn -> :rand.uniform(2) - 1 end)
      |> Enum.take(42)

    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome) do
    Enum.sum(chromosome.genes)
  end

  @impl GeneticLine
  def terminate?([best | _rest]) do
    best.fitness == best.size
  end
end

OneMax
|> PrimordialSoup.evolve(show_progress: true)
|> IO.inspect()
