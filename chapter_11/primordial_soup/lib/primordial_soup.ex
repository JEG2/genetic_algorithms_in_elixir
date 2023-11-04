defmodule PrimordialSoup do
  require Integer

  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.Crossover
  alias PrimordialSoup.Genealogy
  alias PrimordialSoup.Mutation
  alias PrimordialSoup.Reinsertion
  alias PrimordialSoup.Selection
  alias PrimordialSoup.Statistics

  @default_options [
    crossover_repair: nil,
    crossover_type: :single_point,
    fix_population_size: true,
    flip_probability: 0.5,
    mutation_rate: 0.05,
    mutation_type: :scramble,
    population_size: 100,
    record_genealogy: false,
    record_statistics: false,
    reinsertion_type: :pure,
    select_dupes: false,
    selection_rate: 0.8,
    selection_type: :elite,
    show_progress: false,
    statistics_calculator: &Statistics.calculate_statistics/1,
    tournament_size: 3,
    uniform_rate: 0.5,
    whole_arithmetic_alpha: 0.2
  ]

  def evolve(genetic_line, options \\ []) do
    options = Keyword.merge(@default_options, options)

    initialize(&genetic_line.generate/0, options)
    |> evaluate(&genetic_line.score_fitness/1, options)
    |> run(&genetic_line.score_fitness/1, options)
    |> terminate(&genetic_line.terminate?/2, options)
  end

  def initialize(generate, options) do
    population_size = Keyword.fetch!(options, :population_size)
    record_genealogy = Keyword.fetch!(options, :record_genealogy)

    Stream.repeatedly(generate)
    |> Enum.take(population_size)
    |> tap(fn population ->
      if record_genealogy do
        Genealogy.add_chromosomes(population)
      end
    end)
  end

  def run(population, score_fitness, options) do
    record_statistics = Keyword.fetch!(options, :record_statistics)
    statistics_calculator = Keyword.fetch!(options, :statistics_calculator)

    population
    |> Stream.iterate(fn population ->
      {parents, rest} = select(population, options)
      children = cross(parents, options)
      mutants = mutate(population, options)

      reinsertion(parents, children ++ mutants, rest, options)
      |> evaluate(score_fitness, options)
    end)
    |> Stream.with_index()
    |> then(
      &if record_statistics do
        Stream.map(&1, fn {population, generation} ->
          Statistics.insert(generation, statistics_calculator.(population))
          {population, generation}
        end)
      else
        &1
      end
    )
  end

  def evaluate(population, score_fitness, _options) do
    # About 4 times slower:
    #
    # population
    # |> Task.async_stream(
    # fn chromosome ->
    #   %Chromosome{chromosome | fitness: score_fitness.(chromosome)}
    # end,
    # ordered: false
    # )
    # |> Enum.map(fn {:ok, chromosome} -> chromosome end)
    # |> Enum.sort_by(& &1.fitness, :desc)
    population
    |> Enum.map(fn chromosome ->
      %Chromosome{chromosome | fitness: score_fitness.(chromosome)}
    end)
    |> Enum.sort_by(& &1.fitness, :desc)
  end

  def select(population, options) do
    population_size = Keyword.fetch!(options, :population_size)
    selection_type = Keyword.fetch!(options, :selection_type)
    selection_rate = Keyword.fetch!(options, :selection_rate)

    count =
      case round(population_size * selection_rate) do
        n when Integer.is_odd(n) -> n + 1
        n -> n
      end

    parents = apply(Selection, selection_type, [population, count, options])
    rest = population -- parents
    {parents, rest}
  end

  def cross(parents, options) do
    crossover_repair = Keyword.fetch!(options, :crossover_repair)
    crossover_type = Keyword.fetch!(options, :crossover_type)
    record_genealogy = Keyword.fetch!(options, :record_genealogy)

    parents
    |> Enum.chunk_every(2)
    |> Enum.flat_map(fn [p1, p2] ->
      apply(Crossover, crossover_type, [p1, p2, options])
      |> tap(fn [c1, c2] ->
        if record_genealogy do
          Genealogy.add_chromosome(p1, p2, c1)
          Genealogy.add_chromosome(p1, p2, c2)
        end
      end)
    end)
    |> then(
      &if is_nil(crossover_repair) do
        &1
      else
        Enum.map(&1, crossover_repair)
      end
    )
  end

  def mutate(population, options) do
    population_size = Keyword.fetch!(options, :population_size)
    mutation_rate = Keyword.fetch!(options, :mutation_rate)
    mutation_type = Keyword.fetch!(options, :mutation_type)
    record_genealogy = Keyword.fetch!(options, :record_genealogy)

    count = floor(population_size * mutation_rate)

    population
    |> Enum.take_random(count)
    |> Enum.map(fn chromosome ->
      apply(Mutation, mutation_type, [chromosome, options])
      |> tap(fn mutant ->
        if record_genealogy do
          Genealogy.add_chromosome(chromosome, mutant)
        end
      end)
    end)
  end

  defp reinsertion(parents, offspring, rest, options) do
    population_size = Keyword.fetch!(options, :population_size)
    reinsertion_type = Keyword.fetch!(options, :reinsertion_type)
    fix_population_size = Keyword.fetch!(options, :fix_population_size)

    apply(Reinsertion, reinsertion_type, [parents, offspring, rest, options])
    |> tap(fn population ->
      if fix_population_size and length(population) != population_size do
        raise "Variable population size detected"
      end
    end)
  end

  defp terminate(scored_populations, terminate?, options) do
    show_progress = Keyword.fetch!(options, :show_progress)

    scored_populations
    |> Enum.find(fn {[best | _rest], _generation} = {population, generation} ->
      if show_progress do
        :io.format("\rCurrent Best:  ~.4f", [best.fitness])
      end

      terminate?.(population, generation)
    end)
    |> elem(0)
    |> hd()
    |> tap(fn _best ->
      if show_progress do
        IO.write("\n")
      end
    end)
  end
end
