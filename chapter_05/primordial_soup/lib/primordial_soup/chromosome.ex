defmodule PrimordialSoup.Chromosome do
  @type t :: %__MODULE__{
          id: integer(),
          genes: Enum.t(),
          size: integer(),
          fitness: nil | number(),
          age: integer()
        }
  @enforce_keys ~w[id genes size]a
  defstruct [:id, :genes, :size, fitness: nil, age: 0]

  def new(fields) do
    struct!(__MODULE__, Keyword.put(fields, :id, System.unique_integer()))
  end
end
