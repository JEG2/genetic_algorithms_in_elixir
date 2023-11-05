defmodule Schedule do
  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine

  @credit_hours [3.0, 3.0, 3.0, 4.5, 3.0, 3.0, 3.0, 3.0, 4.5, 1.5]
  @difficulties [8.0, 9.0, 4.0, 3.0, 5.0, 2.0, 4.0, 2.0, 6.0, 1.0]
  @usefulness [8.0, 9.0, 6.0, 2.0, 8.0, 9.0, 1.0, 2.0, 5.0, 1.0]
  @interest [8.0, 8.0, 5.0, 9.0, 7.0, 2.0, 8.0, 2.0, 7.0, 10.0]

  @impl GeneticLine
  def generate do
    genes =
      Stream.repeatedly(fn -> Enum.random(0..1) end)
      |> Enum.take(10)

    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome) do
    schedule = chromosome.genes

    total_credits =
      schedule
      |> Enum.zip(@credit_hours)
      |> Enum.map(fn {class, credits} -> class * credits end)
      |> Enum.sum()

    if total_credits > 18 do
      -99_999
    else
      [schedule, @difficulties, @usefulness, @interest]
      |> Enum.zip()
      |> Enum.map(fn {class, d, u, i} ->
        class * (0.3 * u + 0.3 * i - 0.3 * d)
      end)
      |> Enum.sum()
    end
  end

  @impl GeneticLine
  def terminate?(_population, generation), do: generation == 1_000
end

Schedule
|> PrimordialSoup.evolve(
  # crossover_type: :uniform,
  # selection_type: :tournament,
  # mutation_type: :flip,
  show_progress: true
)
|> IO.inspect()
