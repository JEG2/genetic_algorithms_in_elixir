defmodule PrimordialSoup.GeneticLine do
  alias PrimordialSoup.Chromosome

  @callback generate() :: Chromosome.t()
  @callback score_fitness(Chromosome.t()) :: number()
  @callback terminate?(Enum.t()) :: boolean()
end
