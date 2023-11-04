defmodule Mix.Tasks.Compile.PrimordialSoup do
  use Mix.Task.Compiler

  def run(_args) do
    {result, _errcode} =
      System.cmd(
        "gcc",
        ["-fpic", "-shared", "-o", "primordial.so", "src/primordial.c"],
        stderr_to_stdout: true
      )

    IO.puts(result)
  end
end

defmodule PrimordialSoup.MixProject do
  use Mix.Project

  def project do
    [
      app: :primordial_soup,
      compilers: [:primordial_soup] ++ Mix.compilers(),
      version: "0.10.0",
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
      {:exprof, "~> 0.2.4"}
    ]
  end
end
