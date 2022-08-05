defmodule SlackAPIDocs.MixProject do
  use Mix.Project

  def project do
    [
      app: :slack_api_docs,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.33.0", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 1.8", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.3", only: [:dev, :test], runtime: false}
    ]
  end
end
