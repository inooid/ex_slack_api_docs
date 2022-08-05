defmodule Mix.SlackApiDocs.ApiDoc do
  alias Mix.SlackApiDocs.ApiDocArgument

  @valid_content_types [
    "application/x-www-form-urlencoded",
    "application/json",
    "multipart/form-data"
  ]

  @derive Jason.Encoder
  defstruct [
    :name,
    :is_deprecated,
    :desc,
    :content_types,
    :args,
    :response,
    :errors,
    :warnings
  ]

  @type key :: atom | String.t()
  @type t() :: %__MODULE__{
          desc: String.t(),
          content_types: list(String.t()),
          args: %{
            key => ApiDocArgument.t()
          },
          response: map,
          errors: %{
            key => String.t()
          },
          warnings: %{
            key => String.t()
          }
        }

  def add_args!(
        %__MODULE__{args: existing_args} = api_doc,
        arguments
      )
      when is_map(existing_args) do
    Enum.reduce(arguments, api_doc, fn %ApiDocArgument{name: name} = argument, acc ->
      %__MODULE__{acc | args: Map.put(acc.args, name, argument)}
    end)
  end

  def add_args!(%__MODULE__{args: args} = api_doc, arguments) when is_nil(args) do
    add_args!(%__MODULE__{api_doc | args: %{}}, arguments)
  end

  def set_content_types!(%__MODULE__{} = api_doc, content_types) when is_list(content_types) do
    case Enum.all?(content_types, &Enum.member?(@valid_content_types, &1)) do
      true ->
        %__MODULE__{api_doc | content_types: content_types}

      false ->
        raise "Unable to parse content types. Given: #{Jason.encode!(content_types)}, does not match with: #{Jason.encode!(@valid_content_types)}"
    end
  end

  def set_errors!(%__MODULE__{} = api_doc, errors) when is_map(errors) do
    %__MODULE__{api_doc | errors: errors}
  end

  def set_warnings!(%__MODULE__{} = api_doc, warnings) when is_map(warnings) do
    %__MODULE__{api_doc | warnings: warnings}
  end

  def set_response!(%__MODULE__{} = api_doc, response) when is_map(response) do
    %__MODULE__{api_doc | response: response}
  end
end
