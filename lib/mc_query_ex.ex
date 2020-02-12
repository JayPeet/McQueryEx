defmodule McQueryEx do
    require Logger
    defstruct socket: nil, host: {127, 0, 0, 1}, port: 25565, session_id: 1, timeout: 1000

    @magic 0xFEFD
    @defaults %{host: {127, 0, 0, 1}, port: 25565, session_id: 1, timeout: 1000}

    def get_magic() do
      @magic
    end

    def new() do  
      case :gen_udp.open(0, [:binary, active: false]) do
        {:ok, socket} ->    {:ok, %__MODULE__{socket: socket}}
        {:error, reason} -> {:error, reason}
      end
    end

    def new(opts) when is_list(opts)do
      case :gen_udp.open(0, [:binary, active: false]) do
        {:ok, socket} -> 
          combined_opts = Enum.into(opts, @defaults)
          query =  struct(__MODULE__, combined_opts)
          query = %{query | socket: socket}
          {:ok, query}
        {:error, reason} -> 
          {:error, reason}
      end
    end

    def get_basic_stat(q = %__MODULE__{}) do
        {:ok, challenge_number} = get_handshake_challenge(q)

        send_packet(q, McQueryEx.BasicStat.create(q, challenge_number))

        {:ok, resp} =  recv_packet(q)
        McQueryEx.BasicStat.decode_response(resp)
    end

    def get_full_stat(q = %__MODULE__{}) do
      {:ok, challenge_number} = get_handshake_challenge(q)
      send_packet(q, McQueryEx.FullStat.create(q, challenge_number))
      {:ok, resp} =  recv_packet(q)
      McQueryEx.FullStat.decode_response(resp)
    end

    def get_handshake_challenge(q = %__MODULE__{}) do
      send_packet(q, McQueryEx.Handshake.create(q))

      {:ok, resp} = recv_packet(q)

      McQueryEx.Handshake.decode_response(resp)
    end

    defp recv_packet(q = %__MODULE__{host: host, port: port}) do
      case :gen_udp.recv(q.socket, 1024, q.timeout) do
        {:ok, {^host, ^port, resp = <<_type::big-integer-8, session_id::big-integer-32, _payload::binary>>}} -> 
          if session_id == q.session_id do
            {:ok, resp}
          else
            {:error, "Session ID did not match our ID"}
          end
        {:ok, {_, _, _}} -> 
          {:error, "Got packet from someone who wasnt the host."}
        {:error, reason} -> 
          {:error, reason}
      end
    end

    defp send_packet(_q = %__MODULE__{socket: socket, host: host, port: port}, packet) do
      :gen_udp.send(socket, host, port, packet)
    end
end
