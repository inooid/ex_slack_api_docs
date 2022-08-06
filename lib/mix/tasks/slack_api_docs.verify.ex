defmodule Mix.Tasks.SlackApiDocs.Verify do
  use Mix.Task

  @shortdoc "Verifies the local docs against the remote Slack Web API docs"

  @moduledoc """
  Verifies the local docs against the remote Slack Web API docs

  ## Usage

      $ mix slack_api_docs.verify tmp/slack/docs
  """

  alias Mix.SlackApiDocs.{MethodPage, Helpers}

  @command_options [
    concurrency: :integer,
    quiet: :boolean
  ]

  @default_opts [concurrency: 50, quiet: false]

  @impl Mix.Task
  def run(all_args) do
    HTTPoison.start()
    {original_opts, args, _} = OptionParser.parse(all_args, switches: @command_options)
    opts = Keyword.merge(@default_opts, original_opts)
    input_path = List.first(args) || raise "missing input path"
    concurrency = opts[:concurrency]

    original_shell = Mix.shell()
    if opts[:quiet], do: Mix.shell(Mix.Shell.Quiet)

    # Generate files
    Mix.shell().info("Validating local API docs")

    File.ls!(input_path)
    |> Enum.filter(fn file_name -> String.ends_with?(file_name, "json") end)
    |> Enum.map(fn file_name -> "#{input_path}/#{file_name}" end)
    |> Helpers.partition_list(concurrency)
    |> Enum.map(&enqueue_group/1)
    |> Task.await_many(:infinity)

    Mix.shell(original_shell)
  end

  defp compare_local_to_remote!(file_path) do
    Mix.shell().info("Validating: #{file_path}")

    local =
      File.read!(file_path)
      |> Jason.decode!()

    remote =
      MethodPage.gather!(%{
        "link" => local["link"],
        "description" => local["desc"],
        "isDeprecated" => false,
        "name" => local["name"]
      })
      |> Jason.encode!(pretty: true)
      |> Jason.decode!()

    if local == remote do
      :ok
    else
      Mix.shell().error("Difference found between local: #{file_path} and remote.")

      Mix.shell().error(
        "Please run `mix slack_api_docs.gen.json #{Path.dirname(file_path)}` to generate new docs"
      )

      exit({:shutdown, 1})
    end
  end

  defp enqueue_group(group) do
    Task.async(fn ->
      Enum.map(group, fn file_path -> compare_local_to_remote!(file_path) end)
    end)
  end
end
