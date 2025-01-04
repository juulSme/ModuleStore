# ModuleStore

Use a compiled module as a high-performance key-value store. Suitable for low-write, high-read data like global config.

Because every mutation triggers a module recompilation, which requires using a global lock (per node) for mutations to prevent concurrent compilations causing a crash, write performance is awful (by design) and mutations should be kept to a minimum. You can expect write performance to be in the range of 5-25 ops/s. In return, read perfomance sits around 50 million ops/s.

## Installation

The package is hosted on [hex.pm](https://hex.pm/packages/module_store) can be installed by adding `module_store` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:module_store, "~> 0.0.1"}
  ]
end
```

## Docs

Documentation can be found on [hexdocs.pm](https://hexdocs.pm/module_store/).

## Examples / doctests

```elixir
# getter
iex> ModuleStore.new(MyApp.Store, hello: "world!")
iex> MyApp.Store.get(:hello)
"world!"
iex> MyApp.Store.get(:bye)
nil
iex> MyApp.Store.get(:bye, :default)
:default

# getter!
iex> ModuleStore.new(MyApp.Store, hello: "world!")
iex> MyApp.Store.get(:hello)
"world!"
iex> MyApp.Store.get!(:bye)
** (RuntimeError) key not found

# put/get many values
iex> ModuleStore.new(MyApp.Store, hello: "world!")
iex> MyApp.Store.put_all(a: 0, b: 1)
iex> MyApp.Store.get_all()
%{a: 0, b: 1, hello: "world!"}

# delete a value
iex> ModuleStore.new(MyApp.Store, hello: "world!", a: 0)
iex> MyApp.Store.delete(:a)
iex> MyApp.Store.get_all()
%{hello: "world!"}
```

To prevent compiler warnings saying that your store does not exist, call `new/1` somewhere at compile time, for example in a separate .ex file like so:

```elixir
# lib/my_app/module_store.ex
ModuleStore.new(MyApp.Store)
```

## Benchmarks

```console
CPU Information: AMD Ryzen 7 9700X 8-Core Processor
Number of Available Cores: 16
Available memory: 30.94 GB
Elixir 1.18.1
Erlang 27.1.3
JIT enabled: true

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 1 s
memory time: 0 ns
reduction time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 33 s

Name                                         ips        average  deviation         median         99th %
ModuleStore.get_all                      50.53 M       19.79 ns    ±75.50%          20 ns          40 ns
ModuleStore.get! existing                49.34 M       20.27 ns    ±48.48%          20 ns          40 ns
ModuleStore.get existing                 48.74 M       20.52 ns    ±69.64%          20 ns          40 ns
ModuleStore.get missing                  48.64 M       20.56 ns   ±109.02%          20 ns          40 ns
:persistent_term                         31.79 M       31.45 ns ±34487.63%          20 ns          40 ns
ModuleStore.get_all |> Map.get           28.92 M       34.57 ns ±32027.84%          20 ns          50 ns
:persistent_term all |> Map.get          26.97 M       37.08 ns ±29934.47%          30 ns          50 ns
:ets.lookup                              22.01 M       45.44 ns ±15706.91%          40 ns          70 ns
Application.get_env                       6.58 M      152.04 ns  ±4256.18%         131 ns         271 ns
Application.get_env all |> Map.get        1.77 M      564.89 ns   ±823.60%         531 ns         692 ns
ModuleStore.put                        0.00002 M    43935205 ns     ±6.47%    44168826 ns    49045541 ns

Comparison:
ModuleStore.get_all                      50.53 M
ModuleStore.get! existing                49.34 M - 1.02x slower +0.48 ns
ModuleStore.get existing                 48.74 M - 1.04x slower +0.73 ns
ModuleStore.get missing                  48.64 M - 1.04x slower +0.77 ns
:persistent_term                         31.79 M - 1.59x slower +11.66 ns
ModuleStore.get_all |> Map.get           28.92 M - 1.75x slower +14.78 ns
:persistent_term all |> Map.get          26.97 M - 1.87x slower +17.29 ns
:ets.lookup                              22.01 M - 2.30x slower +25.65 ns
Application.get_env                       6.58 M - 7.68x slower +132.25 ns
Application.get_env all |> Map.get        1.77 M - 28.54x slower +545.10 ns
ModuleStore.put                        0.00002 M - 2219906.64x slower +43935185.21 ns
```

So it's as fast as it gets when reading (and it's consistent), but it's atrocious when writing. As advertised.
