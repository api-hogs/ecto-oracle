defmodule EctoOracleAdapter do
  # Inherit all behaviour from Ecto.Adapters.SQL
  use Ecto.Adapters.SQL, :ecto_oracle_adapter

  # And provide a custom storage implementation
  @behaviour Ecto.Adapter.Storage

  ## Storage API

  @doc false
  def storage_up(opts) do
    raise "Not implemented for oracle"
  end

  @doc false
  def storage_down(opts) do
    raise "Not implemented for oracle"
  end

  defp run_with_psql(database, sql_command) do
    raise "Not implemented for oracle"
  end

  @doc false

  def supports_ddl_transaction? do
    false
  end

  defp normalizer(x) do
    case x do
      {:inserted_at, value} ->
        {:inserted_at, elem(Ecto.DateTime.cast(value), 1) |> Ecto.DateTime.to_string}
      _ -> x
    end
  end

  def insert(repo, %{source: {prefix, source}}, params, returning, opts) do
    IO.puts "FFFFFFFFFFFFFFFFFFFFFF"
    normalized_params = :lists.map(&normalizer/1, params)
    IO.inspect normalized_params
    {fields, values} = :lists.unzip(params)
    IO.inspect values
    sql = @conn.insert(prefix, source, fields, [fields], returning, values)
    Ecto.Adapters.SQL.struct(repo, @conn, sql, values, returning, opts)
  end
end
