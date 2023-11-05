defmodule CrossoverTest do
  use ExUnit.Case
  use ExUnitProperties
  alias PrimordialSoup.Chromosome

  property "single_point/2 maintains the size of input chromosomes" do
    check all(
            size <- integer(2..100),
            gene_1 <- list_of(integer(), length: size),
            gene_2 <- list_of(integer(), length: size)
          ) do
      p1 = Chromosome.new(genes: gene_1, size: size)
      p2 = Chromosome.new(genes: gene_2, size: size)
      [c1, c2] = PrimordialSoup.Crossover.single_point(p1, p2, [])
      assert c1.size == size and c2.size == size
    end
  end
end
