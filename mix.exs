defmodule Dslcheck.Mixfile do
  use Mix.Project

  def project do
    [app: :dslcheck,
     escript: escript_config,
     version: "0.1.0",
     name: "DSL Check",
     source_url: "https://github.com/mauricerkelly/dslcheck",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: """
     A module to query dslchecker.bt.com for VDSL status at a specified
     property number, address or telephone number.
     """]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [ applications: [ :logger, :httpoison ] ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      { :httpoison, "~> 0.9" },
      { :floki, "~> 0.10.1" }
    ]
  end

  defp escript_config do
    [ main_module: Dslcheck.CLI ]
  end
end
