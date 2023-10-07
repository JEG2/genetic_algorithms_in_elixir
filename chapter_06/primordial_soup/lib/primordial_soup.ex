defmodule PrimordialSoup do
  require Integer

  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.Crossover
  alias PrimordialSoup.Selection

  @default_options [
    crossover_repair: nil,
    crossover_type: :single_point,
    population_size: 1_000,
    select_dupes: false,
    selection_rate: 0.8,
    selection_type: :elite,
    show_progress: false,
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

  defp initialize(generate, options) do
    population_size = Keyword.fetch!(options, :population_size)

    Stream.repeatedly(generate)
    |> Enum.take(population_size)
  end

  defp run(population, score_fitness, options) do
    population
    |> Stream.iterate(fn population ->
      population
      |> select(options)
      |> recombine(options)
      |> mutate(options)
      |> evaluate(score_fitness, options)
    end)
    |> Stream.with_index()
  end

  defp evaluate(population, score_fitness, _options) do
    population
    |> Enum.map(fn chromosome ->
      %Chromosome{chromosome | fitness: score_fitness.(chromosome)}
    end)
    |> Enum.sort_by(& &1.fitness, :desc)
  end

  defp select(population, options) do
    population_size = Keyword.fetch!(options, :population_size)
    selection_type = Keyword.fetch!(options, :selection_type)
    selection_rate = Keyword.fetch!(options, :selection_rate)

    count =
      case round(population_size * selection_rate) do
        n when Integer.is_odd(n) -> n + 1
        n -> n
      end

    paired = apply(Selection, selection_type, [population, count, options])
    unpaired = population -- paired

    {Enum.chunk_every(paired, 2), unpaired}
  end

  defp recombine({paired, unpaired}, options) do
    crossover_repair = Keyword.fetch!(options, :crossover_repair)
    crossover_type = Keyword.fetch!(options, :crossover_type)

    paired
    |> Enum.flat_map(fn [p1, p2] ->
      apply(Crossover, crossover_type, [p1, p2, options])
    end)
    |> Kernel.++(unpaired)
    |> then(
      &if is_nil(crossover_repair) do
        &1
      else
        Enum.map(&1, crossover_repair)
      end
    )
  end

  defp mutate(population, _options) do
    Enum.map(population, fn chromosome ->
      if :rand.uniform() < 0.05 do
        %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
      else
        chromosome
      end
    end)
  end

  defp terminate(scored_populations, terminate?, options) do
    show_progress = Keyword.fetch!(options, :show_progress)

    scored_populations
    |> Enum.find(fn {[best | _rest], _generation} = {population, generation} ->
      if show_progress do
        IO.write("\rCurrent Best:  #{best.fitness}")
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
