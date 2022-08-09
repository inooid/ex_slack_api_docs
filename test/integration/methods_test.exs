defmodule Test.Integration.MethodTest do
  use ExUnit.Case, async: true

  alias Mix.SlackApiDocs.MethodPage
  alias Mix.SlackApiDocs.{ApiDoc, MethodPage, ApiDocArgument}

  @post_message_args [
    "token",
    "channel",
    "attachments",
    "blocks",
    "text",
    "as_user",
    "icon_emoji",
    "icon_url",
    "link_names",
    "metadata",
    "mrkdwn",
    "parse",
    "reply_broadcast",
    "thread_ts",
    "unfurl_links",
    "unfurl_media",
    "username"
  ]

  describe "chat.postMessage" do
    test "should return correct %ApiDoc{}" do
      assert api_doc =
               %ApiDoc{} =
               MethodPage.gather!(%{
                 "name" => "chat.postMessage",
                 "description" => "Sends a message to a channel.",
                 "isDeprecated" => false,
                 "link" => "/methods/chat.postMessage"
               })

      # Assert mostly static fields
      assert %ApiDoc{
               name: "chat.postMessage",
               desc: "Sends a message to a channel.",
               link: "/methods/chat.postMessage",
               is_deprecated: false,
               response: %{
                 "channel" => "C123456",
                 "message" => %{},
                 "ok" => true,
                 "ts" => "1503435956.000247"
               }
             } = api_doc

      # Assert that all arguments are present
      assert_all_in_list(@post_message_args, Map.keys(api_doc.args))

      # All arguments should be of: `ApiDocArgument` type
      assert Enum.all?(api_doc.args, fn {_key, value} ->
               assert %ApiDocArgument{} = value
             end)

      # Should support conditionally required arguments
      assert String.contains?(
               api_doc.args["attachments"].desc,
               "Required unless `blocks`, `text` is passed."
             )

      assert String.contains?(
               api_doc.args["blocks"].desc,
               "Required unless `attachments`, `text` is passed."
             )

      assert String.contains?(
               api_doc.args["text"].desc,
               "Required unless `attachments`, `blocks` is passed."
             )

      refute Enum.empty?(api_doc.errors)
      refute Enum.empty?(api_doc.content_types)
      refute Enum.empty?(api_doc.warnings)
    end
  end

  defp assert_all_in_list(expected_list, given_list) do
    assert Enum.all?(expected_list, fn value -> Enum.member?(given_list, value) end),
           """
           Error: missing expected items in list.

           missing:
               - #{list_missing_args(given_list) |> Enum.join("\n    - ")}

           given:
           #{Jason.encode!(Enum.sort(given_list))}

           expected:
           #{Jason.encode!(Enum.sort(expected_list))}
           """
  end

  defp list_missing_args(args) do
    Enum.filter(@post_message_args, fn name -> !Enum.member?(args, name) end)
  end
end
