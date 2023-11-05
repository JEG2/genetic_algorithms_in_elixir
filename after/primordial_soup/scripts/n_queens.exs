defmodule NQueens do
  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine

  @impl GeneticLine
  def generate do
    genes = Enum.shuffle(0..7)
    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome) do
    diagonal_clashes =
      for i <- 0..7, j <- 0..7, i != j do
        dx = abs(i - j)
        dy = abs(Enum.at(chromosome.genes, i) - Enum.at(chromosome.genes, j))

        if dx == dy do
          1
        else
          0
        end
      end

    length(Enum.uniq(chromosome.genes)) - Enum.sum(diagonal_clashes)
  end

  @impl GeneticLine
  def terminate?([best | _rest], _generation) do
    best.fitness == 8
  end
end

NQueens
|> PrimordialSoup.evolve(
  show_progress: true,
  population_size: 100,
  crossover_repair: fn chromosome ->
    missing = [0, 1, 2, 3, 4, 5, 6, 7] -- chromosome.genes

    %PrimordialSoup.Chromosome{
      chromosome
      | genes: Enum.uniq(chromosome.genes) ++ Enum.shuffle(missing)
    }
  end
)
|> IO.inspect()

NQueens
|> PrimordialSoup.evolve(
  show_progress: true,
  population_size: 100,
  crossover_type: :order_one
)
|> IO.inspect()
