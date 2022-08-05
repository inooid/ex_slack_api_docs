defmodule Mix.Tasks.SlackApiDocs.Gen.Json do
  use Mix.Task

  @shortdoc "Generates Slack Web API docs in JSON format"

  @moduledoc """
  Generates Slack API docs in a given format
  """

  @base_uri "https://api.slack.com"
  @base_endpoint "methods"

  @dir System.tmp_dir() <> "slack_api_docs"

  @impl Mix.Task
  def run(args) do
    try do
      HTTPoison.start()

      {opts, _, _} = OptionParser.parse(args, switches: [target: :string, concurrency: :integer])
      target_path = Keyword.fetch!(opts, :target)
      concurrency = Keyword.get(opts, :concurrency, 50)

      File.mkdir_p!(@dir)
      Mix.shell().info("Gathering API methods, concurrency: #{concurrency}")

      get!(@base_endpoint)
      |> Mix.SlackApiDocs.HomePage.gather_methods!()
      |> partition(concurrency)
      |> Enum.map(fn group -> enqueue_group(group) end)
      |> Task.await_many(:infinity)

      Mix.shell().info("Copying files to: #{target_path}")
      copy_from_tmp!(target_path)
    after
      System.cmd("rm", ["-r", @dir])
    end
  end

  defp process_api_doc(%{"link" => link, "name" => name} = item) do
    Mix.shell().info("Generating: #{name}")

    contents =
      get!(link)
      |> Mix.SlackApiDocs.MethodPage.gather!(item)
      |> Jason.encode!(pretty: true)

    File.write!("#{@dir}/#{name}.json", contents)
  end

  defp enqueue_group(group) do
    Task.async(fn ->
      Enum.map(group, fn item -> process_api_doc(item) end)
    end)
  end

  defp partition(list, size) when is_integer(size) and size > 0 do
    pool_size =
      (Enum.count(list) / size)
      |> Float.ceil()
      |> Kernel.trunc()

    Enum.chunk_every(list, pool_size)
  end

  defp get!(url) do
    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.get!("#{@base_uri}/#{String.trim_leading(url, "/")}")

    body
  end

  defp copy_from_tmp!(target_path) do
    File.mkdir_p!(target_path)

    File.ls!(@dir)
    |> Enum.filter(fn file -> String.ends_with?(file, "json") end)
    |> Enum.map(fn file ->
      origin = "#{@dir}/#{file}"
      dest = "#{String.trim_trailing(target_path, "/")}/#{file}"
      File.cp!(origin, dest)
    end)
  end
end
