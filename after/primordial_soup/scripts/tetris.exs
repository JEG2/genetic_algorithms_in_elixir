defmodule Tetris do
  defmodule Interface do
    use Agent

    def start_link(path_to_tetris_rom) do
      game =
        Alex.new()
        |> Alex.set_option(:display_screen, true)
        |> Alex.set_option(:sound, true)
        |> Alex.set_option(:random_seed, 123)
        |> Alex.load(path_to_tetris_rom)

      Agent.start_link(fn -> game end, name: __MODULE__)
    end

    def actions do
      Agent.get(TetrisInterface, & &1.legal_actions)
    end

    def play(actions) do
      Agent.get(TetrisInterface, fn game ->
        reward =
          actions
          |> Enum.reduce(game, fn action -> Alex.step(game, action) end)
          |> Map.fetch!(:reward)

        Alex.reset(game)

        reward
      end)
    end
  end

  alias PrimordialSoup.Chromosome
  alias PrimordialSoup.GeneticLine

  @behaviour GeneticLine

  @impl GeneticLine
  def generate do
    actions = Interface.actions()

    genes =
      Stream.repeatedly(fn -> Enum.random(actions) end)
      |> Enum.take(1_000)

    Chromosome.new(genes: genes, size: length(genes))
  end

  @impl GeneticLine
  def score_fitness(chromosome), do: Interface.play(chromosome.genes)

  @impl GeneticLine
  def terminate?(_population, generation), do: generation == 5
end

:primordial_soup
|> :code.priv_dir()
|> then(&Path.expand("tetris.bin", &1))
|> Tetris.Interface.start_link()

Tetris
|> PrimordialSoup.evolve(population_size: 10)
|> IO.inspect()
