# MagikaEx [![Hex.pm Version](https://img.shields.io/hexpm/v/magika_ex?style=flat-square)](https://hex.pm/packages/magika_ex) [![Hex.pm Docs](https://img.shields.io/badge/docs-hexpm-purple?style=flat-square)](https://hexdocs.pm/magika_ex)

MagikaEx is an Elixir wrapper for [Magika](https://github.com/google/magika), using [Rustler](https://github.com/rusterlium/rustler).

This module is community-made and is **NOT an official Google project**.

## Prerequisites

- Elixir 1.18+
- Erlang/OTP 26+
- Rust 1.92.0+

## Installation

The package can be installed by adding `magika_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:magika_ex, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
iex> {:ok, result} = MagikaEx.identify_file("path/to/file")
...> IO.puts("Detected type: #{result.label}")
```

## Support and Contribution

**This module is experimental.** I do not offer active support, so please use it at your own risk.

At this time, I am not accepting external contributions such as PRs or feature requests.

## License

This project is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## Authors

- [Minoru Maekawa](https://github.com/err931)
