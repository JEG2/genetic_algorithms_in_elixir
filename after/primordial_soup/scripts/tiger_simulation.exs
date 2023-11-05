defmodule TigerSimulation do
  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine

  # @tropic_scores [0.0, 3.0, 2.0, 1.0, 0.5, 1.0, -1.0, 0.0]
  @tundra_scores [1.0, 3.0, -2.0, -1.0, 0.5, 2.0, 1.0, 0.0]

  @impl GeneticLine
  def generate do
    genes =
      Stream.repeatedly(fn -> Enum.random(0..1) end)
      |> Enum.take(8)

    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome) do
    chromosome.genes
    |> Enum.zip(@tundra_scores)
    |> Enum.map(fn {trait, score} -> trait * score end)
    |> Enum.sum()
  end

  @impl GeneticLine
  def terminate?(_population, generation), do: generation == 150

  def average_tiger(population) do
    genes = Enum.map(population, & &1.genes)
    scores = Enum.map(population, & &1.fitness)
    ages = Enum.map(population, & &1.age)
    num_tigers = length(population)

    avg_fitness = Enum.sum(scores) / num_tigers
    avg_age = Enum.sum(ages) / num_tigers

    avg_genes =
      genes
      |> Enum.zip()
      |> Enum.map(fn traits -> Enum.sum(Tuple.to_list(traits)) / num_tigers end)

    %{
      average_tiger:
        Chromosome.new(
          genes: avg_genes,
          size: length(avg_genes),
          age: avg_age,
          fitness: avg_fitness
        )
    }
  end
end

# TigerSimulation
# |> PrimordialSoup.evolve(
#   population_size: 2,
#   show_progress: true,
#   record_genealogy: true
# )
# |> IO.inspect()

# genealogy = PrimordialSoup.Genealogy.get_tree()
# {:ok, dot} = Graph.Serializers.DOT.serialize(genealogy)
# File.write!("tiger_simulation.dot", dot, [:binary])

TigerSimulation
|> PrimordialSoup.evolve(
  population_size: 20,
  show_progress: true,
  record_statistics: true
)
|> IO.inspect()

stats =
  PrimordialSoup.Statistics.dump()
  |> Enum.map(fn {generation, fields} -> [generation, fields.mean_fitness] end)

Gnuplot.plot(
  [
    [:set, :title, "mean fitness versus generation"],
    [:plot, "-", :with, :points]
  ],
  [stats]
)
