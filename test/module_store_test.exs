defmodule ModuleStoreTest do
  use ExUnit.Case
  doctest ModuleStore

  test "greets the world" do
    assert ModuleStore.hello() == :world
  end
end
