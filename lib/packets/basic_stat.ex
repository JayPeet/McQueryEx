defmodule McQueryEx.BasicStat do
  defstruct(
    motd: "",
    game_type: "SMP",
    map: "",
    num_players: 0,
    max_players: 20,
    host_port: 0,
    host_ip: ""
  )

  def create(%McQueryEx{session_id: id}, challenge) do
    <<
      McQueryEx.get_magic()::big-integer-16,
      0::big-integer-8,
      id::big-integer-32,
      challenge::big-integer-32
    >>
  end

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

    %__MODULE__{
      motd: motd,
      game_type: game_type, 
      map: map, 
      num_players: num_players,
      max_players: max_players,
      host_port: host_port,
      host_ip: host_ip
    }
  end


  def decode_response(_incorrect_response) do
    {:error, "BasicStat response was malformed."}
  end
end
