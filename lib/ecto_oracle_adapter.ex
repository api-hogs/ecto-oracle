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
    true
  end

  def insert(repo, %{source: {prefix, source}} = schema_meta, params, returning, opts) do
    sorted_params = Enum.sort(params)
    {fields, values} = :lists.unzip(sorted_params)
    types = Enum.sort(schema_meta.schema.__schema__(:types))
    IO.inspect types
    sql = @conn.insert(prefix, source, fields, [fields], returning)
    Ecto.Adapters.SQL.struct(repo, @conn, sql, sorted_params, returning, Keyword.merge(opts, [types: types]))
  end
end
