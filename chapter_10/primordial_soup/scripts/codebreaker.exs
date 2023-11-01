defmodule Codebreaker do
  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine

  @unencrypted "ILoveGeneticAlgorithms"
  @encrypted ~c{LIjs`B`k`qlfDibjwlqmhv}

  @impl GeneticLine
  def generate do
    genes =
      Stream.repeatedly(fn -> Enum.random(0..1) end)
      |> Enum.take(64)

    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome) do
    key =
      chromosome.genes
      |> Enum.join()
      |> String.to_integer(2)

    guess = decrypt(@encrypted, key)
    String.jaro_distance(@unencrypted, guess)
  end

  @impl GeneticLine
  def terminate?([best | _rest], _generation) do
    best.fitness == 1
  end

  def decrypt(encrypted, key) do
    encrypted
    |> Enum.map(fn char -> char |> Bitwise.bxor(key) |> rem(32_768) end)
    |> to_string()
  end
end

solution =
  PrimordialSoup.evolve(
    Codebreaker,
    mutation_type: :flip,
    show_progress: true
  )

key =
  solution.genes
  |> Enum.join()
  |> String.to_integer(2)
  |> IO.inspect()

unencrypted = Codebreaker.decrypt(~c{LIjs`B`k`qlfDibjwlqmhv}, key)
IO.inspect(key: key, unencrypted: unencrypted)
