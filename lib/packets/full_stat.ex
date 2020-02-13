defmodule McQueryEx.FullStat do
  @moduledoc """
  McQueryEx.FullStat creates FullStat requests, and decodes FullStat responses into a struct.
  """

    defstruct(
        basic: %McQueryEx.BasicStat{},
        server_version: "0.0.0",
        plugins: "",
        players: []
      )
    
  
  @typedoc """
  Encapsulates the full stat response.
  """
  @type t :: %__MODULE__{
    basic: McQueryEx.BasicStat.t(),
    server_version: String.t(),
    plugins: String.t(),
    players: list()
  }

  @spec create(McQueryEx.t(), integer()) :: <<_::120>>
  def create(%McQueryEx{session_id: id}, challenge) do
    <<
      McQueryEx.get_magic()::big-integer-16,
      0::big-integer-8,
      id::big-integer-32,
      challenge::big-integer-32,
      0::big-integer-32
    >>
  end

  @spec decode_response(binary()) :: {:ok, __MODULE__.t()}
  def decode_response(<<0::big-integer-8, session_id::big-integer-32, "splitnum", 0x00, 0x80, 0x00, payload::binary>>) do
    [
      #KV Segment of fullstat response.
      "hostname",
      motd,
      "gametype",
      game_type,
      "game_id",
      "MINECRAFT",
      "version",
      server_version,
      "plugins",
      plugins,
      "map",
      map,
      "numplayers",
      num_players,
      "maxplayers",
      max_players,
      "hostport",
      host_port_string,
      "hostip",
      host_ip,
      "",
      #Dumb padding.
      <<0x01, 0x70, 0x6C, 0x61, 0x79, 0x65, 0x72, 0x5F>>
      | players
    ] = String.split(payload, "\0")

    basic = %McQueryEx.BasicStat{
      motd: motd,
      game_type: game_type, 
      map: map, 
      num_players: num_players,
      max_players: max_players,
      host_port: String.to_integer(host_port_string),
      host_ip: host_ip
    }

    {:ok,
      %__MODULE__{
        basic: basic, 
        server_version: server_version, 
        plugins: plugins, 
        players: Enum.filter(players, &(&1 != ""))
      }
    }
  end

  @spec decode_response(any()) :: {:error, String.t()}
  def decode_response(_incorrect_response) do
    {:error, "Full Stat response was malformed."}
  end
end