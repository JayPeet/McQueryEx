defmodule McQueryEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :mc_query_ex,
      version: "0.3.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      # Docs
      name: "McQueryEx",
      source_url: "https://github.com/jaypeet/mc_query_ex",
      docs: [
      main: "McQueryEx",
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
    ]
  end

  defp description() do
    "An Elixir module for making requests to a Minecraft servers query interface."
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jaypeet/mc_query_ex"}
    ]
  end
end
