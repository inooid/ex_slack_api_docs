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

      # Should support required arguments
      assert %ApiDocArgument{
               name: "channel",
               required: true,
               example: channel_example,
               type: "string",
               desc: channel_desc
             } = api_doc.args["channel"]

      assert "" != channel_example
      assert "" != channel_desc

      # Should support conditionally required arguments
      assert %ApiDocArgument{
               name: "blocks",
               required: false,
               example: blocks_example,
               type: "blocks[] as string",
               desc: blocks_desc
             } = api_doc.args["blocks"]

      assert "" != blocks_example
      assert "" != blocks_desc

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

      # Should support optional arguments
      assert %ApiDocArgument{
               name: "as_user",
               required: false,
               example: as_user_example,
               type: "boolean",
               desc: as_user_desc
             } = api_doc.args["as_user"]

      assert "" != as_user_example
      assert "" != as_user_desc

      # Any of these fields should not be empty
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
