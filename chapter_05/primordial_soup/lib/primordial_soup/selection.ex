defmodule PrimordialSoup.Selection do
  def elite(population, count, _options) do
    Enum.take(population, count)
  end

  def random(population, count, _options) do
    Enum.take_random(population, count)
  end

  def tournament(population, count, options) do
    select_dupes = Keyword.fetch!(options, :select_dupes)

    if select_dupes do
      tournament_with_dupes(population, count, options)
    else
      tournament_without_dupes(population, count, options)
    end
  end

  # increases population size over time
  def tournament_with_dupes(population, count, options) do
    tournament_size = Keyword.fetch!(options, :tournament_size)

    Stream.repeatedly(fn ->
      population
      |> random(tournament_size, options)
      |> Enum.max_by(fn chromosome -> chromosome.fitness end)
    end)
    |> Enum.take(count)
  end

  def tournament_without_dupes(population, count, options) do
    tournament_size = Keyword.fetch!(options, :tournament_size)

    Stream.iterate({population, 0}, fn {remaining, used} ->
      winner =
        remaining
        |> random(tournament_size, options)
        |> Enum.max_by(fn chromosome -> chromosome.fitness end)

      {remaining -- [winner], used + 1}
    end)
    |> Enum.find(fn {_population, used} -> used == count end)
    |> elem(0)
  end

  def roulette(population, count, options) do
    select_dupes = Keyword.fetch!(options, :select_dupes)

    if select_dupes do
      roulette_with_dupes(population, count, options)
    else
      roulette_without_dupes(population, count, options)
    end
  end

  # increases population size over time
  def roulette_with_dupes(population, count, _options) do
    total_fitness =
      population
      |> Enum.map(fn chromosome -> chromosome.fitness end)
      |> Enum.sum()

    Stream.repeatedly(fn ->
      choice = :rand.uniform() * total_fitness

      Enum.reduce_while(population, 0, fn chromosome, sum ->
        sum = sum + chromosome.fitness

        if sum > choice do
          {:halt, chromosome}
        else
          {:cont, sum}
        end
      end)
    end)
    |> Enum.take(count)
  end

  def roulette_without_dupes(population, count, _options) do
    Stream.unfold(population, fn remaining ->
      total_fitness =
        remaining
        |> Enum.map(fn chromosome -> chromosome.fitness end)
        |> Enum.sum()

      choice = :rand.uniform() * total_fitness

      winner =
        Enum.reduce_while(remaining, 0, fn chromosome, sum ->
          sum = sum + chromosome.fitness

          if sum > choice do
            {:halt, chromosome}
          else
            {:cont, sum}
          end
        end)

      {winner, remaining -- [winner]}
    end)
    |> Enum.take(count)
  end
end
