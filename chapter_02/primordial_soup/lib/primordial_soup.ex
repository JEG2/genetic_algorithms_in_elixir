defmodule PrimordialSoup do
  @default_options [
    population_size: 100,
    show_progress: false
  ]

  def evolve(functions, target_score, options \\ []) do
    options = Keyword.merge(@default_options, options)

    initialize(&functions.generate/0, options)
    |> run(&functions.score_fitness/1, options)
    |> terminate(target_score, options)
  end

  defp initialize(generate, options) do
    Stream.repeatedly(generate)
    |> Enum.take(Keyword.fetch!(options, :population_size))
  end

  defp run(population, score_fitness, options) do
    population
    |> Stream.iterate(fn generation ->
      generation
      |> evaluate(score_fitness, options)
      |> select(options)
      |> recombine(options)
      |> mutate(options)
    end)
    |> Stream.map(fn generation ->
      find_best(generation, score_fitness, options)
    end)
  end

  defp evaluate(population, score_fitness, _options) do
    Enum.sort_by(population, score_fitness, :desc)
  end

  defp select(population, _options) do
    Enum.chunk_every(population, 2)
  end

  defp recombine(population, _options) do
    Enum.flat_map(population, fn [p1, p2] ->
      cx_point = :rand.uniform(1_001) - 1
      {h1, t1} = Enum.split(p1, cx_point)
      {h2, t2} = Enum.split(p2, cx_point)
      [h1 ++ t2, h2 ++ t1]
    end)
  end

  defp mutate(population, _options) do
    Enum.map(population, fn chromosome ->
      if :rand.uniform() < 0.05 do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end

  defp find_best(population, score_fitness, options) do
    population
    |> Enum.map(fn chromosomes ->
      {score_fitness.(chromosomes), chromosomes}
    end)
    |> Enum.max()
    |> tap(fn {score, _chromosomes} ->
      if Keyword.fetch!(options, :show_progress) do
        IO.write("\rCurrent Best:  #{score}")
      end
    end)
  end

  defp terminate(scored_population, target_score, options) do
    scored_population
    |> Enum.find(fn {score, _chromosomes} -> score == target_score end)
    |> elem(1)
    |> tap(fn _best ->
      if Keyword.fetch!(options, :show_progress) do
        IO.write("\n")
      end
    end)
  end
end
