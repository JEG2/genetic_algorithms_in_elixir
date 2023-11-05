defmodule PrimordialSoup.Mutation do
  @moduledoc false

  alias PrimordialSoup.Chromosome

  def flip(chromosome, options) do
    flip_probability = Keyword.fetch!(options, :flip_probability)

    genes =
      Enum.map(chromosome.genes, fn g ->
        if :rand.uniform() < flip_probability do
          Bitwise.bxor(g, 1)
        else
          g
        end
      end)

    %Chromosome{chromosome | genes: genes}
  end

  def scramble(chromosome, _options) do
    %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
  end

  def gaussian(chromosome, _options) do
    mean = Enum.sum(chromosome.genes) / chromosome.size

    standard_deviation =
      chromosome.genes
      |> Enum.map(fn g -> (mean - g) * (mean - g) end)
      |> Enum.sum()
      |> Kernel./(chromosome.size)

    genes =
      Enum.map(chromosome.genes, fn _g ->
        :rand.normal(mean, standard_deviation)
      end)

    %Chromosome{chromosome | genes: genes}
  end

  def regenerate(chromosome, options) do
    regenerate_probability = Keyword.fetch!(options, :regenerate_probability)
    regenerate_choices = Keyword.fetch!(options, :regenerate_choices)

    genes =
      Enum.map(chromosome.genes, fn g ->
        if :rand.uniform() < regenerate_probability do
          Enum.random(regenerate_choices)
        else
          g
        end
      end)

    %Chromosome{chromosome | genes: genes}
  end
end
