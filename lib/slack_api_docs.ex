defmodule SlackApiDocs do
  @moduledoc false
  use Application

  def start(_, _) do
    Mix.shell().info("""
    Warning: the `slack_api_docs` application's start function was called, which likely means you
    did not add the dependency with the `runtime: false` flag. This is not recommended because
    it will mean that unnecessary applications are started.
    Please add `runtime: false` in your `mix.exs` dependency section e.g.:
    {:slack_api_docs, "~> 0.1", only: [:dev], runtime: false}
    """)

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
