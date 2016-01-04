defmodule EctoOracleAdapterTest do
  use ExUnit.Case, async: true

  alias EctoOracleAdapter.Connection

  @user "system"
  @password "oracle"
  @tns "(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=46.101.228.77)(PORT= 49161)))(CONNECT_DATA=(SERVICE_NAME=XE)))"
  @credentials %{ tns: @tns, user: @user, password: @password}

  test "connect" do
    {:ok, conn} = Connection.connect(%{ credentials: @credentials })

    assert conn
  end

  test "disconnect" do
    {:ok, conn} = Connection.connect(%{ credentials: @credentials })

    assert Connection.disconnect(conn)
  end

end
