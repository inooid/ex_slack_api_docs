defmodule Mix.SlackApiDocs.MethodPage do
  @moduledoc false

  alias Mix.SlackApiDocs.{ApiDoc, ApiDocArgument, Request}

  @elements %{
    # Facts
    facts_content_types: ".apiReference__factBlock--contentTypes code",

    # Arguments
    required_args_list: ".apiMethodPage__argumentList----required .apiMethodPage__argumentRow",
    argument_groups_list:
      ".apiMethodPage__argumentSection .apiMethodPage__argumentGroup .apiMethodPage__argumentRow",
    optional_args_list: ".apiMethodPage__argumentList----optional .apiMethodPage__argumentRow",
    argument_name: ".apiMethodPage__argument",
    argument_description: ".apiMethodPage__argumentDesc p",
    argument_type: ".apiMethodPage__argumentType",
    argument_example: ".apiReference__exampleCode",

    # Example responses
    example_responses: ".apiReference__response .apiReference__example pre",

    # Errors
    errors_table_rows: ".apiReference__errors table > tr",
    errors_table_error_code: "td[data-label=\"Error\"]",
    errors_table_error_description: "td[data-label=\"Description\"]",

    # Warnings
    warnings_table_rows: ".apiReference__warnings table > tr",
    warnings_table_warning_code: "td[data-label=\"Warning\"]",
    warnings_table_warning_description: "td[data-label=\"Description\"]"
  }

  @spec gather!(map) :: ApiDoc.t()
  def gather!(%{
        "link" => link,
        "description" => description,
        "isDeprecated" => is_deprecated,
        "name" => name
      }) do
    document =
      Request.get!(link)
      |> Floki.parse_document!()

    %ApiDoc{
      name: name,
      link: link,
      desc: description,
      is_deprecated: is_deprecated
    }
    |> attach_content_types!(document)
    |> attach_required_args!(document)
    |> attach_conditionally_required_args!(document)
    |> attach_optional_args!(document)
    |> attach_errors!(document)
    |> attach_warnings!(document)
    |> attach_response!(document)
  end

  defp attach_content_types!(%ApiDoc{} = api_doc, html_document) do
    content_types =
      html_document
      |> Floki.find(@elements.facts_content_types)
      |> Enum.map(&Floki.text/1)

    ApiDoc.set_content_types!(api_doc, content_types)
  end

  defp attach_required_args!(%ApiDoc{} = api_doc, html_document) do
    ApiDoc.add_args!(
      api_doc,
      Floki.find(html_document, @elements.required_args_list)
      |> parse_arguments!(is_required: true)
    )
  end

  defp attach_optional_args!(%ApiDoc{} = api_doc, html_document) do
    ApiDoc.add_args!(
      api_doc,
      Floki.find(html_document, @elements.optional_args_list)
      |> parse_arguments!(is_required: false)
    )
  end

  defp attach_conditionally_required_args!(%ApiDoc{} = api_doc, html_document) do
    ApiDoc.add_args!(
      api_doc,
      Floki.find(html_document, @elements.argument_groups_list)
      |> parse_arguments!(is_required: false)
      |> mark_as_conditionally_required()
    )
  end

  defp parse_arguments!(args_list_element, is_required: is_required) do
    args_list_element
    |> Enum.map(fn argument ->
      # The type is not always shown, so we fallback to the type "string"
      type =
        case Floki.find(argument, @elements.argument_type) |> Floki.text() do
          "" -> "string"
          t -> t
        end

      %ApiDocArgument{
        name: Floki.find(argument, @elements.argument_name) |> Floki.text(),
        desc: Floki.find(argument, @elements.argument_description) |> Floki.text(),
        example: Floki.find(argument, @elements.argument_example) |> Floki.text(),
        type: type,
        required: is_required
      }
    end)
  end

  defp mark_as_conditionally_required(arguments) do
    argument_names = arguments |> Enum.map(fn %ApiDocArgument{name: name} -> name end)

    arguments
    |> Enum.map(fn %ApiDocArgument{desc: desc} = argument ->
      # Find all BUT the current argument
      relevant_names =
        Enum.filter(argument_names, fn name ->
          name != argument.name
        end)

      %ApiDocArgument{
        argument
        | desc: "Required unless `#{relevant_names |> Enum.join("`, `")}` is passed. #{desc}"
      }
    end)
  end

  defp attach_errors!(%ApiDoc{} = api_doc, html_document) do
    errors =
      html_document
      |> Floki.find(@elements.errors_table_rows)
      |> Enum.map(fn row ->
        code = Floki.find(row, @elements.errors_table_error_code) |> Floki.text()
        desc = Floki.find(row, @elements.errors_table_error_description) |> Floki.text()

        {code, desc}
      end)
      |> Enum.into(%{}, fn tuple -> tuple end)

    ApiDoc.set_errors!(api_doc, errors)
  end

  defp attach_warnings!(%ApiDoc{} = api_doc, html_document) do
    warnings =
      html_document
      |> Floki.find(@elements.warnings_table_rows)
      |> Enum.map(fn row ->
        code = Floki.find(row, @elements.warnings_table_warning_code) |> Floki.text()
        desc = Floki.find(row, @elements.warnings_table_warning_description) |> Floki.text()

        {code, desc}
      end)
      |> Enum.into(%{}, fn tuple -> tuple end)

    ApiDoc.set_warnings!(api_doc, warnings)
  end

  defp attach_response!(%ApiDoc{} = api_doc, html_document) do
    response =
      html_document
      |> Floki.find(@elements.example_responses)
      |> Enum.map(fn element -> Floki.text(element) end)
      |> Enum.find(&String.contains?(&1, "\"ok\": true"))
      |> case do
        nil ->
          %{"ok" => true}

        response ->
          response
          |> Jason.decode!()
      end

    ApiDoc.set_response!(api_doc, response)
  end
end
