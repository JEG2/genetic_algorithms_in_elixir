defmodule PrimordialSoup.Crossover do
  alias PrimordialSoup.Chromosome

  def single_point(p1, p2, _options) do
    cx_point = rem(PrimordialSoup.xor96(), p1.size - 1)
    {h1, t1} = Enum.split(p1.genes, cx_point)
    {h2, t2} = Enum.split(p2.genes, cx_point)

    [
      %Chromosome{p1 | genes: h1 ++ t2, age: p1.age + 1},
      %Chromosome{p2 | genes: h2 ++ t1, age: p2.age + 1}
    ]
  end

  def order_one(p1, p2, _options) do
    limit = p1.size - 1
    [i1, i2] = Enum.sort([:rand.uniform(limit), :rand.uniform(limit)])

    slice1 = Enum.slice(p1.genes, i1..i2)
    {head1, tail1} = Enum.split(p2.genes -- slice1, i1)

    slice2 = Enum.slice(p2.genes, i1..i2)
    {head2, tail2} = Enum.split(p1.genes -- slice2, i1)

    [
      %Chromosome{p1 | genes: head2 ++ slice2 ++ tail2, age: p1.age + 1},
      %Chromosome{p2 | genes: head1 ++ slice1 ++ tail1, age: p2.age + 1}
    ]
  end

  def uniform(p1, p2, options) do
    uniform_rate = Keyword.fetch!(options, :uniform_rate)

    {genes1, genes2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        if :rand.uniform() < uniform_rate do
          {x, y}
        else
          {y, x}
        end
      end)
      |> Enum.unzip()

    [
      %Chromosome{p1 | genes: genes1, age: p1.age + 1},
      %Chromosome{p2 | genes: genes2, age: p2.age + 1}
    ]
  end

  def whole_arithmetic(p1, p2, options) do
    whole_arithmetic_alpha = Keyword.fetch!(options, :whole_arithmetic_alpha)

    {genes1, genes2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        {
          x * whole_arithmetic_alpha + y * (1 - whole_arithmetic_alpha),
          x * (1 - whole_arithmetic_alpha) + y * whole_arithmetic_alpha
        }
      end)
      |> Enum.unzip()

    [
      %Chromosome{p1 | genes: genes1, age: p1.age + 1},
      %Chromosome{p2 | genes: genes2, age: p2.age + 1}
    ]
  end
end
