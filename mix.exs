# Copyright (c) 2022 Mathieu Kerjouan
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#
#  3. Neither the name of the copyright holder nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

defmodule Visma.MixProject do
  use Mix.Project

  def project do
    [
      app: :visma,
      name: "Visma",
      description: "Visma API implementation in pure Elixir.",
      package: package(),
      docs: docs(),
      source_urls: "https://gitlab.com/kfmak/visma",
      homepage_url: "https://gitlab.com/kfmak/visma",
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [docs: :docs],
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
      {:doctor, "~> 0.19.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
    ]
  end

  defp aliases, do: [setup: ["deps.get"]]

  defp docs do
    [
      source_ref: "v0.1.0",
      main: "overview",
      formatters: ["html", "epub"],
      groups_for_functions: [
        "Reflection": &(&1[:type] == :reflection)
      ],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp package do
    [
      maintainers: ["Mathieu Kerjouan"],
      licenses: ["BSD 3-Clauses"],
      links: %{
        "Gitlab" => "https://gitlab.com/kfmak/visma",
        "GitHub" => "https://github.com/kfmak/visma"
      },
      files:
        ~w(assets/js lib priv CHANGELOG.md LICENSE.md mix.exs package.json README.md .formatter.exs)
    ]
  end
end
