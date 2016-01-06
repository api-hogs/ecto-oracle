defmodule EctoOracleAdapter.Result do

  @type t :: %__MODULE__{
    command:  atom,
    columns:  [String.t] | nil,
    rows:     [[term] | term] | nil,
    num_rows: integer,
    decoders: [(term -> term)] | nil}

  defstruct [command: nil, columns: nil, rows: nil, num_rows: nil,
             decoders: nil]

  @spec decode(t, ([term] -> term)) :: t
  def decode(result_set, mapper \\ fn x -> x end)

  def decode(res, mapper) do
    case res do
      {:rowids, ids} -> 
      # CHECK THIS
        %EctoOracleAdapter.Result{rows: Enum.map(ids, fn x -> [ id: x ] end), decoders: nil, num_rows: length(ids), columns: nil}
      # {_column, _int1, number_of_records, _, _} when number_of_records == 0 -> []
      _ -> %EctoOracleAdapter.Result{rows: [], decoders: nil, num_rows: nil, columns: nil}
    end
  end
end
