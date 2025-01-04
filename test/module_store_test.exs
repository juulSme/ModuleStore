defmodule ModuleStoreTest do
  use ExUnit.Case, async: true

  ModuleStore.new(MyApp.Store)

  describe "new/1" do
    test "can handle concurrent requests" do
      1..10
      |> Enum.map(fn n ->
        Task.async(fn -> MyApp.Store.put(n, :value) end)
      end)
      |> Task.await_many()
      |> Enum.find(:ok, &(&1 != :ok))
      |> then(fn result -> assert result == :ok end)
    end
  end

  doctest ModuleStore
end
