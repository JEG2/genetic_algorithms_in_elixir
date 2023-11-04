defmodule FakeProblem do
  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine

  @impl GeneticLine
  def generate do
    genes =
      Stream.repeatedly(fn -> Enum.random(0..1) end)
      |> Enum.take(100)

    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome), do: Enum.sum(chromosome.genes)

  @impl GeneticLine
  def terminate?(_population, generation), do: generation == 1
end

population =
  PrimordialSoup.initialize(&FakeProblem.generate/0,
    population_size: 100,
    record_genealogy: false
  )

{selected_population, _} =
  PrimordialSoup.select(population,
    population_size: 100,
    selection_type: :elite,
    selection_rate: 1.0
  )

Benchee.run(
  %{
    "initialize" => fn ->
      PrimordialSoup.initialize(&FakeProblem.generate/0,
        population_size: 100,
        record_genealogy: false
      )
    end,
    "evaluate" => fn ->
      PrimordialSoup.evaluate(population, &FakeProblem.score_fitness/1, [])
    end,
    "select" => fn ->
      PrimordialSoup.select(population,
        population_size: 100,
        selection_type: :elite,
        selection_rate: 1.0
      )
    end,
    "crossover" => fn ->
      PrimordialSoup.cross(selected_population,
        crossover_repair: nil,
        crossover_type: :single_point,
        record_genealogy: false
      )
    end,
    "mutation" => fn ->
      PrimordialSoup.mutate(population,
        population_size: 100,
        mutation_rate: 0.05,
        mutation_type: :scramble,
        record_genealogy: false
      )
    end,
    "evolve" => fn ->
      PrimordialSoup.evolve(FakeProblem,
        population_size: 100
      )
    end
  },
  memory_time: 2
)
