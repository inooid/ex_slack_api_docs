defmodule Mix.Tasks.SlackApiDocs.Gen.Json do
  use Mix.Task
  @default_output_path "tmp/slack/docs"
  @tmp_dir String.trim_trailing(System.tmp_dir(), "/") <> "/slack_api_docs"

  @shortdoc "Generates Slack Web API docs in JSON format"

  @moduledoc """
  Generates Slack API docs in JSON format

  ## Usage

      $ mix slack_api_docs.gen.json
      $ mix slack_api_docs.gen.json tmp/slack/docs
  """

  alias Mix.SlackApiDocs.{HomePage, MethodPage, Request, Helpers}

  @command_options [
    concurrency: :integer,
    quiet: :boolean
  ]

  @default_opts [concurrency: 50, quiet: false]

  @impl Mix.Task
  def run(all_args) do
    {original_opts, args, _} = OptionParser.parse(all_args, switches: @command_options)
    opts = Keyword.merge(@default_opts, original_opts)
    output_path = List.first(args) || @default_output_path
    concurrency = opts[:concurrency]

    original_shell = Mix.shell()
    if opts[:quiet], do: Mix.shell(Mix.Shell.Quiet)

    try do
      # Setup
      HTTPoison.start()
      File.mkdir_p!(@tmp_dir)

      # Generate files
      Mix.shell().info("Gathering API methods, concurrency: #{concurrency}")

      Request.get!("/methods")
      |> HomePage.gather_methods!()
      |> Helpers.partition_list(concurrency)
      |> Enum.map(&enqueue_group/1)
      |> Task.await_many(:infinity)

      # Copy the files over to the target location
      Mix.shell().info("Copying files to: #{output_path}")
      copy_to_target!(output_path)
    after
      System.cmd("rm", ["-rf", @tmp_dir])
    end

    Mix.shell(original_shell)
  end

  defp write_json_for_endpoint!(%{"name" => name} = item) do
    Mix.shell().info("Generating: #{name}")

    contents =
      MethodPage.gather!(item)
      |> Jason.encode!(pretty: true)

    File.write!("#{@tmp_dir}/#{name}.json", contents)
  end

  defp enqueue_group(group) do
    Task.async(fn ->
      Enum.map(group, fn item -> write_json_for_endpoint!(item) end)
    end)
  end

  defp copy_to_target!(output_path) do
    File.mkdir_p!(output_path)

    File.ls!(@tmp_dir)
    |> Enum.filter(fn file -> String.ends_with?(file, "json") end)
    |> Enum.map(fn file ->
      origin = "#{@tmp_dir}/#{file}"
      dest = "#{String.trim_trailing(output_path, "/")}/#{file}"
      File.cp!(origin, dest)
    end)
  end
end
