defmodule Mix.SlackApiDocs.ApiDocArgument do
  @enforce_keys [
    :name,
    :required,
    :example,
    :type,
    :desc
  ]

  @derive Jason.Encoder
  defstruct [
    :name,
    :required,
    :example,
    :type,
    :desc
  ]

  @type t() :: %__MODULE__{
          name: String.t(),
          required: boolean(),
          example: String.t(),
          type: String.t(),
          desc: String.t()
        }
end
