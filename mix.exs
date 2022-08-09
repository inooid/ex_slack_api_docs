defmodule SlackAPIDocs.MixProject do
  use Mix.Project

  @source_url "https://github.com/inooid/ex_slack_api_docs"
  @version "0.1.1"

  def project do
    [
      app: :slack_api_docs,
      version: @version,
      elixir: ">= 1.11.0",
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.33.0"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.3"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
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

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: @version,
      extras: ["CHANGELOG.md", "README.md"]
    ]
  end
end
