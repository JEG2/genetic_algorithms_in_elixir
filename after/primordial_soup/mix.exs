defmodule PrimordialSoup.MixProject do
  use Mix.Project

  def project do
    [
      app: :primordial_soup,
      version: "0.11.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {PrimordialSoup.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libgraph, "~> 0.16.0"},
      {:gnuplot, "~> 1.22"},
      {:benchee, "~> 1.1"},
      {:exprof, "~> 0.2.4"},
      {:stream_data, "~> 0.6.0", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end
end
