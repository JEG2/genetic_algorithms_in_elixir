defmodule PrimordialSoup do
  alias PrimordialSoup.Chromosome

  @default_options [
    population_size: 100,
    show_progress: false
  ]

  def evolve(genetic_line, options \\ []) do
    options = Keyword.merge(@default_options, options)

    initialize(&genetic_line.generate/0, options)
    |> evaluate(&genetic_line.score_fitness/1, options)
    |> run(&genetic_line.score_fitness/1, options)
    |> terminate(&genetic_line.terminate?/2, options)
  end

  defp initialize(generate, options) do
    Stream.repeatedly(generate)
    |> Enum.take(Keyword.fetch!(options, :population_size))
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

  defp select(population, _options) do
    Enum.chunk_every(population, 2)
  end

  defp recombine(population, _options) do
    Enum.flat_map(population, fn [p1, p2] ->
      cx_point = :rand.uniform(p1.size - 1)
      {h1, t1} = Enum.split(p1.genes, cx_point)
      {h2, t2} = Enum.split(p2.genes, cx_point)

      [
        %Chromosome{p1 | genes: h1 ++ t2, age: p1.age + 1},
        %Chromosome{p2 | genes: h2 ++ t1, age: p2.age + 1}
      ]
    end)
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
