defmodule Visma.MixProject do
  use Mix.Project

  def project do
    [
      app: :visma,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [
        summary: [
          threshold: 0
        ],
        ignore_modules: [
        ]
      ]
    ]
  end

  def application, do: [
      mod: {Visma.Application, []},
      extra_applications: [:logger, :runtime_tools]
  ]

  defp elixirc_paths(:test), do: ["lib", "test/support"]

  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:ecto, "~> 3.8"},
    ]
  end

  defp aliases, do: [setup: ["deps.get"]]
end
