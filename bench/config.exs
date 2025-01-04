alias MyApp.Store
config = for n <- 1..100, do: {String.to_atom("test_#{n}"), "value"}
config_map = Map.new(config)

# ModuleStore
ModuleStore.new(Store, config_map)

# :persistent_term
:persistent_term.put(:bench_all, config_map)
for {k, v} <- config_map, do: :persistent_term.put(k, v)

# ETS
table = :ets.new(:test, [])
:ets.insert(table, config)

# Application environment
Application.put_env(:module_store, Store, config_map)
for {k, v} <- config_map, do: Application.put_env(:module_store, k, v)

Benchee.run(
  %{
    "ModuleStore.get existing" => fn -> Store.get(:test_50) end,
    "ModuleStore.get! existing" => fn -> Store.get(:test_50) end,
    "ModuleStore.get missing" => fn -> Store.get(:not_found) end,
    "ModuleStore.get_all" => fn -> Store.get_all() end,
    "ModuleStore.get_all |> Map.get" => fn -> Store.get_all() |> Map.get(:test_50) end,
    "ModuleStore.put" => fn -> Store.put(:a, :b) end,
    ":persistent_term" => fn -> :persistent_term.get(:test_50) end,
    ":persistent_term all |> Map.get" => fn ->
      :persistent_term.get(:bench_all) |> Map.get(:test_50)
    end,
    "Application.get_env all |> Map.get" => fn ->
      Application.get_env(:module_store, Store) |> Map.get(:test_50)
    end,
    "Application.get_env" => fn ->
      Application.get_env(:module_store, :test_50)
    end,
    ":ets.lookup" => fn ->
      [test_50: base] = :ets.lookup(table, :test_50)
      base
    end
  },
  time: 1,
  parallel: 1
)
