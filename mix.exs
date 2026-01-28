defmodule MagikaEx.MixProject do
  use Mix.Project

  @source_url "https://github.com/err931/magika_ex"
  @version "0.1.1"

  def project do
    [
      app: :magika_ex,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Elixir NIF wrapper for google/magika",
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {MagikaEx.Application, []}
    ]
  end

  defp package do
    [
      maintainers: ["Minoru Maekawa"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib native .formatter.exs mix.exs README.md LICENSE)
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:rustler, "~> 0.37.1", runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      source_ref: "v#{@version}"
    ]
  end
end
