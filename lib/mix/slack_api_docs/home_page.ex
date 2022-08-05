defmodule Mix.SlackApiDocs.HomePage do
  @elements %{
    react_root: "[data-automount-component=\"ApiDocsFilterableReferenceList\"]"
  }

  @spec gather_methods!(binary) :: list(%{})
  def gather_methods!(body) do
    Floki.parse_document!(body)
    |> Floki.find(@elements.react_root)
    |> get_react_props!()
    |> Map.fetch!("items")
    |> filter_deprecated()
  end

  defp get_react_props!([{_element, attributes, _child_nodes} | _]) do
    {"data-automount-props", raw_props} = Enum.find(attributes, &is_automount_props_attribute/1)

    raw_props
    |> Jason.decode!()
  end

  defp is_automount_props_attribute({key, _value}), do: key == "data-automount-props"

  defp filter_deprecated(items) do
    Enum.filter(items, fn item -> item["isDeprecated"] == false end)
  end
end
