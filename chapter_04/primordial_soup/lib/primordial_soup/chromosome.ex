defmodule PrimordialSoup.Chromosome do
  @type t :: %__MODULE__{
          genes: Enum.t(),
          size: integer(),
          fitness: nil | number(),
          age: integer()
        }
  @enforce_keys ~w[genes size]a
  defstruct [:genes, :size, fitness: nil, age: 0]

  def new(fields), do: struct!(__MODULE__, fields)
end
