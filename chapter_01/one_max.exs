# population
Stream.repeatedly(fn ->
  Stream.repeatedly(fn ->
    :rand.uniform(2) - 1
  end)
  |> Enum.take(1_000)
end)
|> Enum.take(100)
# algorithm
|> Stream.iterate(fn population ->
  population
  # evaluate
  |> Enum.sort_by(&Enum.sum/1, :desc)
  # selection
  |> Enum.chunk_every(2)
  # crossover
  |> Enum.flat_map(fn [p1, p2] ->
    cx_point = :rand.uniform(1_001) - 1
    {h1, t1} = Enum.split(p1, cx_point)
    {h2, t2} = Enum.split(p2, cx_point)
    [h1 ++ t2, h2 ++ t1]
  end)
  # mutation
  |> Enum.map(fn chromosome ->
    if :rand.uniform() < 0.05 do
      Enum.shuffle(chromosome)
    else
      chromosome
    end
  end)
end)
|> Stream.map(fn population ->
  population
  |> Enum.map(fn chromosomes -> {Enum.sum(chromosomes), chromosomes} end)
  |> Enum.max()
  |> tap(fn {count, _chromosomes} ->
    IO.write("\rCurrent Best:  #{count}")
  end)
end)
|> Enum.find(fn {count, _chromosomes} -> count == 1_000 end)
|> elem(1)
|> then(fn solution ->
  IO.puts("\nAnswer:")
  IO.inspect(solution)
end)
