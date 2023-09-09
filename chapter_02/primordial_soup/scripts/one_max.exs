defmodule OneMax do
  def generate do
    Stream.repeatedly(fn -> :rand.uniform(2) - 1 end)
    |> Enum.take(1_000)
  end

  def score_fitness(chromosomes) do
    Enum.sum(chromosomes)
  end
end

OneMax
|> PrimordialSoup.evolve(1_000, show_progress: true)
|> IO.inspect()
