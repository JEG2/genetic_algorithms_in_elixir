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
  def terminate?(_population, generation), do: generation == 1_000
end

defmodule Profiler do
  import ExProf.Macro

  def do_analyze do
    profile do
      PrimordialSoup.evolve(FakeProblem, population_size: 100)
    end
  end

  def run do
    {records, _block_result} = do_analyze()
    total_percent = Enum.reduce(records, 0.0, &(&1.percent + &2))
    IO.puts("total = #{total_percent}")
  end
end

Profiler.run()
