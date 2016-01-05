defmodule EctoOracleAdapter.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @adapters [:oracle]

  def project do
    [app: :ecto_oracle_adapter,
     version: @version,
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,

     test_paths: test_paths(Mix.env),

     aliases: ["test.all": ["test", "test.adapters"],
               "test.adapters": &test_adapters/1],

     preferred_cli_env: ["test.all": :test],

   ]
  end

  def application do
    [applications: [:logger, :ecto, :erloci]]
  end

  defp test_paths(adapter) when adapter in @adapters, do: ["integration_test/#{adapter}"]
  defp test_paths(_), do: ["test"]

  defp deps do
    [{:erloci, git: "git://github.com/K2InformaticsGmbH/erloci.git"},
      {:ecto, git: "git://github.com/elixir-lang/ecto.git"}]
  end

  defp test_adapters(args) do
    for env <- @adapters, do: env_run(env, args)
  end

  defp env_run(env, args) do
    args = if IO.ANSI.enabled?, do: ["--color"|args], else: ["--no-color"|args]

    IO.puts "==> Running tests for MIX_ENV=#{env} mix test"
    {_, res} = System.cmd "mix", ["test"|args],
                          into: IO.binstream(:stdio, :line),
                          env: [{"MIX_ENV", to_string(env)}]

    if res > 0 do
      System.at_exit(fn _ -> exit({:shutdown, 1}) end)
    end
  end
end
