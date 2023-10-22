defmodule Speller do
  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine

  @impl GeneticLine
  def generate do
    genes =
      Stream.repeatedly(fn -> Enum.random(?a..?z) end)
      |> Enum.take(34)

    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome) do
    chromosome.genes
    |> List.to_string()
    |> String.jaro_distance("supercalifragilisticexpialidocious")
  end

  @impl GeneticLine
  def terminate?([best | _rest], _generation) do
    best.fitness == 1
  end
end

Speller
|> PrimordialSoup.evolve(
  show_progress: true,
  crossover_type: :uniform,
  uniform_rate: 0.1
)
|> IO.inspect()
