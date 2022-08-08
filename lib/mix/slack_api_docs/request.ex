defmodule Mix.SlackApiDocs.Request do
  @moduledoc false

  @base_uri "https://api.slack.com"

  def get!(url) do
    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.get!("#{@base_uri}/#{String.trim_leading(url, "/")}")

    body
  end
end
