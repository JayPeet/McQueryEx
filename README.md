# McQueryEx
[![Build status](https://travis-ci.org/JayPeet/mc_query_ex.svg "Build status")](https://travis-ci.org/JayPeet/mc_query_ex)
[![Hex version](https://img.shields.io/hexpm/v/mc_query_ex.svg "Hex version")](https://hex.pm/packages/mc_query_ex)
![Hex downloads](https://img.shields.io/hexpm/dt/mc_query_ex.svg "Hex downloads")

An Elixir module for making requests to a Minecraft servers query interface.

## Contributing
Contributions are always welcome. Feel free to make an issue to discuss a feature or bug.

## Examples

```elixir
iex> {:ok, query} = McQueryEx.new(host: {192, 168, 0, 20}, port: 25565)
{:ok,
 %McQueryEx{
   host: {192, 168, 0, 20},
   port: 25565,
   session_id: 1,
   socket: #Port<0.4>,
   timeout: 1000
 }}

iex> {:ok, full_stats} = McQueryEx.get_full_stat(query)
{:ok,
 %McQueryEx.FullStat{
   basic: %McQueryEx.BasicStat{
     game_type: "SMP",
     host_ip: "192.168.0.20",
     host_port: 25575,
     map: "world",
     max_players: "20",
     motd: "Welcome to McQueryEx!",
     num_players: "0"
   },
   players: ["jay_x_peet", "elixir"],
   plugins: "",
   server_version: "1.12.2"
 }}
```