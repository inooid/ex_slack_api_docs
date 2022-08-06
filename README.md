# `mix slack_api_docs.gen.json`

A mix task for generating JSON API docs based on the Slack API.
The format is similar to the deprecated repository: https://github.com/slackhq/slack-api-docs.

## Installation

You can either add it as a dependency in your `mix.exs`, or install it globally as an archive task.

To add it to a mix project, just add a line like this in your deps function in mix.exs:

```elixir
def deps do
  [
    {:slack_api_docs, "~> 0.1.0", only: [:dev], runtime: false}
  ]
end
```

```console
mix do deps.get, deps.compile
```

## Usage

```console
mix slack_api_docs.gen.json lib/slack/web/docs
```

### Command line options

- `--concurrency 75` - default: 50, the amount of requests running in parallel
