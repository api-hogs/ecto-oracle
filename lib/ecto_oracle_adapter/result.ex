defmodule EctoOracleAdapter.Result do

  @type t :: %__MODULE__{
    command:  atom,
    columns:  [String.t] | nil,
    rows:     [[term] | term] | nil,
    num_rows: integer,
    decoders: [(term -> term)] | nil}

  defstruct [command: nil, columns: nil, rows: nil, num_rows: nil,
             decoders: nil]

  defp normalize(res) do
    rows = case hd(res) do
      {_column, _int1, number_of_records, _, _} when number_of_records == 0 -> []
      _ -> []
    end

    %EctoOracleAdapter.Result{ decoders: nil, rows: rows }
  end

  @spec decode(t, ([term] -> term)) :: t
  def decode(result_set, mapper \\ fn x -> x end)

  def decode(%EctoOracleAdapter.Result{decoders: nil} = res, _mapper), do: normalize(res)

  def decode(res, mapper) do
    %EctoOracleAdapter.Result{rows: rows, decoders: decoders} = normalize(res)
    rows = decode(rows, decoders, mapper, [])
    %EctoOracleAdapter.Result{normalize(res) | rows: rows, decoders: nil}
  end

  defp decode([row | rows], decoders, mapper, decoded) do
    decoded = [mapper.(decode_row(row, decoders)) | decoded]
    decode(rows, decoders, mapper, decoded)
  end
  defp decode([], _, _, decoded), do: decoded

  defp decode_row([nil | rest], [_ | decoders]) do
    [nil | decode_row(rest, decoders)]
  end
  defp decode_row([elem | rest], [decode | decoders]) do
    [decode.(elem) | decode_row(rest, decoders)]
  end
  defp decode_row([], []), do: []
end
