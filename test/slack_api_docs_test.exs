defmodule SlackAPIDocsTest do
  use ExUnit.Case
  doctest SlackAPIDocs

  test "greets the world" do
    assert SlackAPIDocs.hello() == :world
  end
end
