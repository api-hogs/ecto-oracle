Logger.configure(level: :info)
ExUnit.start

# Configure Ecto for support and tests
Application.put_env(:ecto, :lock_for_update, "FOR UPDATE")
Application.put_env(:ecto, :primary_key_type, :id)

# Configure ORACLE connection
Application.put_env(:ecto, :credentials, %{
  user: "system",
  password: "oracle",
  tns: "(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=46.101.228.77)(PORT= 49161)))(CONNECT_DATA=(SERVICE_NAME=XE)))"
})

# Load support files
Code.require_file "../support/repo.exs", __DIR__
Code.require_file "../support/schemas.exs", __DIR__
Code.require_file "../support/migration.exs", __DIR__

pool =
  case System.get_env("ECTO_POOL") || "poolboy" do
    "poolboy"        -> Ecto.Pools.Poolboy
    "sojourn_broker" -> Ecto.Pools.SojournBroker
  end

# Basic test repo
alias EctoOracleAdapter.Integration.TestRepo

Application.put_env(:ecto, TestRepo,
  adapter: EctoOracleAdapter,
  credentials: Application.get_env(:ecto, :credentials),
  pool: Ecto.Adapters.SQL.Sandbox)

defmodule EctoOracleAdapter.Integration.TestRepo do
  use EctoOracleAdapter.Integration.Repo, otp_app: :ecto

  def create_prefix(prefix) do
    "create schema #{prefix}"
  end

  def drop_prefix(prefix) do
    "drop schema #{prefix}"
  end
end

# Pool repo for transaction and lock tests
alias EctoOracleAdapter.Integration.PoolRepo

Application.put_env(:ecto, PoolRepo,
  adapter: EctoOracleAdapter,
  pool: pool,
  credentials: Application.get_env(:ecto, :credentials),
  pool_size: 10)

defmodule EctoOracleAdapter.Integration.PoolRepo do
  use EctoOracleAdapter.Integration.Repo, otp_app: :ecto
end

defmodule EctoOracleAdapter.Integration.Case do
  use ExUnit.CaseTemplate

  setup_all do
    Ecto.Adapters.SQL.begin_test_transaction(TestRepo, [])
    on_exit fn -> Ecto.Adapters.SQL.rollback_test_transaction(TestRepo, []) end
    :ok
  end

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(TestRepo, [])
    :ok
  end
end

# Load up the repository, start it, and run migrations
{:ok, _pid} = TestRepo.start_link
{:ok, _pid} = PoolRepo.start_link

schema_table = %Ecto.Migration.Table{name: "schema_migrations"}
users_table = %Ecto.Migration.Table{name: "users"}
posts_table = %Ecto.Migration.Table{name: "posts"}
posts_users_table = %Ecto.Migration.Table{name: "posts_users"}
users_posts_table = %Ecto.Migration.Table{name: "users_posts"}
transactions_table = %Ecto.Migration.Table{name: "transactions"}
try do
  TestRepo.__adapter__.execute_ddl(TestRepo, {:drop, schema_table}, [])
  TestRepo.__adapter__.execute_ddl(TestRepo, {:drop_cascade, users_table}, [])
  TestRepo.__adapter__.execute_ddl(TestRepo, {:drop_cascade, posts_table}, [])
  TestRepo.__adapter__.execute_ddl(TestRepo, {:drop, posts_users_table}, [])
  TestRepo.__adapter__.execute_ddl(TestRepo, {:drop, users_posts_table}, [])
  TestRepo.__adapter__.execute_ddl(TestRepo, {:drop, transactions_table}, [])
rescue
  e in RuntimeError -> e
end
:ok = Ecto.Migrator.up(TestRepo, 0, EctoOracleAdapter.Integration.Migration, log: false)
Process.flag(:trap_exit, true)
