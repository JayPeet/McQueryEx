defmodule McQueryEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :mc_query_ex,
      version: "0.2.0",
      elixir: "~> 1.7",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      # Docs
      name: "McQueryEx",
      source_url: "https://github.com/jaypeet/mc_query_ex",
      #homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
      docs: [
      main: "McQueryEx", # The main page in the docs
      #logo: "path/to/logo.png",
      #extras: ["README.md"]
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
      files: ~w(lib priv .formatter.exs mix.exs README* readme* LICENSE*
                license* CHANGELOG* changelog* src),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jaypeet/mc_query_ex"}
    ]
  end
end
