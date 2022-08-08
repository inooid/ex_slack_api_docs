defmodule SlackAPIDocs.MixProject do
  use Mix.Project

  @source_url "https://github.com/inooid/ex_slack_api_docs"
  @version "0.1.0"

  def project do
    [
      app: :slack_api_docs,
      version: @version,
      elixir: ">= 1.10.0",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.33.0", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 1.8", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.3", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Mix tasks to generate JSON files from the Slack Web API docs.
    """
  end

  defp package do
    [
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE"
      ],
      maintainers: ["Boyd Dames"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
