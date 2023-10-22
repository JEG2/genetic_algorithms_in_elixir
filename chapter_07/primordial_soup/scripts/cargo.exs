defmodule Cargo do
  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine

  @profits [6, 5, 8, 9, 6, 7, 3, 1, 2, 6]
  @weights [10, 6, 8, 7, 10, 9, 7, 11, 6, 8]

  @impl GeneticLine
  def generate do
    genes =
      Stream.repeatedly(fn -> Enum.random(0..1) end)
      |> Enum.take(10)

    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome) do
    if weigh(chromosome.genes) > 40 do
      0
    else
      price(chromosome.genes)
    end
  end

  @impl GeneticLine
  def terminate?(_population, generation) do
    generation == 1_000
  end

  def weigh(genes), do: muliply_and_sum(genes, @weights)
  def price(genes), do: muliply_and_sum(genes, @profits)

  defp muliply_and_sum(genes, multiples) do
    genes
    |> Enum.zip(multiples)
    |> Enum.map(fn {gene, multiple} -> gene * multiple end)
    |> Enum.sum()
  end
end

best = PrimordialSoup.evolve(Cargo, show_progress: true)
IO.puts("Load:    #{inspect(best.genes)}")
IO.puts("Weight:  #{Cargo.weigh(best.genes)}")
IO.puts("Profit:  #{best.fitness}")
