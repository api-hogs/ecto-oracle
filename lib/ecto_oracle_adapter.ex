defmodule EctoOracleAdapter do
  # Inherit all behaviour from Ecto.Adapters.SQL
  use Ecto.Adapters.SQL, :oracle

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
end
