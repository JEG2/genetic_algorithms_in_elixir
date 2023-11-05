defmodule Speller do
  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine
  @target String.graphemes("supercalifragilisticexpialidocious")

  @impl GeneticLine
  def generate do
    genes =
      Stream.repeatedly(fn -> Enum.random(?a..?z) end)
      |> Enum.take(34)

    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome) do
    word =
      chromosome.genes
      |> List.to_string()
      |> String.graphemes()

    Enum.zip(word, @target)
    |> Enum.map(fn
      {letter, letter} -> 1
      _different -> 0
    end)
    |> Enum.sum()
  end

  @impl GeneticLine
  def terminate?([best | _rest], _generation) do
    best.fitness == best.size
  end
end

Speller
|> PrimordialSoup.evolve(
  show_progress: true,
  progress_function: fn best ->
    :io.format(
      "\rCurrent Best:  ~s ~b",
      [List.to_string(best.genes), best.fitness]
    )
  end,
  mutation_type: :regenerate,
  reinsertion_type: :elitist,
  regenerate_probability: 0.1,
  regenerate_choices: ?a..?z,
  selection_type: :tournament
)
|> IO.inspect()
