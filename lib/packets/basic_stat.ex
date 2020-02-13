defmodule McQueryEx.BasicStat do
  @moduledoc """
  McQueryEx.BasicStat creates BasicStat requests, and decodes BasicStat responses into a struct.
  """
  defstruct(
    motd: "",
    game_type: "SMP",
    map: "",
    num_players: 0,
    max_players: 20,
    host_port: 0,
    host_ip: ""
  )

  @typedoc """
  Encapsulates the basic stat response. Also used within the full stat response for storing a portion of the data.
  """
  @type t :: %__MODULE__{
    motd: String.t(),
    game_type: String.t(),
    map: String.t(),
    num_players: integer(),
    max_players: integer(),
    host_port: integer(),
    host_ip: String.t()
  }

  @spec create(McQueryEx.t(), integer()) :: <<_::88>>
  def create(%McQueryEx{session_id: id}, challenge) do
    <<
      McQueryEx.get_magic()::big-integer-16,
      0::big-integer-8,
      id::big-integer-32,
      challenge::big-integer-32
    >>
  end

  @spec decode_response(binary()) :: {:ok, __MODULE__.t()}
  def decode_response(<<0::big-integer-8, _session_id::big-integer-32, payload::binary>>) do
    [
      motd,
      game_type,
      map,
      num_players,
      max_players,
      <<host_port::big-integer-16, host_ip::binary>>,
      ""
    ] = String.split(payload, "\0")

    {:ok ,
      %__MODULE__{
        motd: motd,
        game_type: game_type, 
        map: map, 
        num_players: String.to_integer(num_players),
        max_players: String.to_integer(max_players),
        host_port: host_port,
        host_ip: host_ip
      }
    }
  end

  @spec decode_response(any()) :: {:error, String.t()}
  def decode_response(_incorrect_response) do
    {:error, "BasicStat response was malformed."}
  end
end
