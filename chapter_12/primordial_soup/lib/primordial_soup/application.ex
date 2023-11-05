defmodule PrimordialSoup.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {PrimordialSoup.Statistics, []},
      {PrimordialSoup.Genealogy, []}
    ]

    options = [strategy: :one_for_one, name: PrimordialSoup.Supervisor]
    Supervisor.start_link(children, options)
  end
end
