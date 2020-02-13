defmodule McQueryEx do
   @moduledoc """
   McQueryEx provides an interface for using Minecrafts server query.
   """
    require Logger
    defstruct socket: nil, host: {127, 0, 0, 1}, port: 25565, session_id: 1, timeout: 1000

  @typedoc """
    The McQueryEx struct, returned from new/0 and new/1
  """
  @type t :: %__MODULE__{
    socket: nil | port(),
    host: tuple(),
    port: integer(),
    session_id: integer(),
    timeout: integer()
  }

    @magic 0xFEFD
    @defaults %{host: {127, 0, 0, 1}, port: 25565, session_id: 1, timeout: 1000}

    @doc false
    def get_magic() do
      @magic
    end

    @doc """
    Create a McQueryEx struct, with the default options.

    Returns `McQueryEx.t()`

    ## Examples

        iex> query = McQueryEx.new()
        %McQueryEx{}
    """
    @spec new() :: {:ok, __MODULE__.t()} | {:error, String.t()}
    def new() do  
      case :gen_udp.open(0, [:binary, active: false]) do
        {:ok, socket} ->    {:ok, %__MODULE__{socket: socket}}
        {:error, reason} -> {:error, reason}
      end
    end

    @doc """
    Create a McQueryEx struct, with the specified options.

    Returns `McQueryEx.t()`

    ## Examples

        iex> query = McQueryEx.new(host: {192, 168, 0, 150}, timeout: 100)
        %McQueryEx{}
    """
    @spec new([host: tuple(), port: integer(), session_id: integer(), timeout: integer()]) :: {:ok, __MODULE__.t()} | {:error, String.t()}
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

    @doc """
    Pulls the basic stats from the MC server.

    Returns `McQueryEx.BasicStat.t()`

    ## Examples

        iex> query = McQueryEx.new(host: {192, 168, 0, 150}, port: 25565)
        iex> basic_stats = McQueryEx.get_basic_stat(query)
        %McQueryEx.BasicStat{}
    """
    @spec get_basic_stat(__MODULE__.t()) :: McQueryEx.BasicStat.t()
    def get_basic_stat(q = %__MODULE__{}) do
        {:ok, challenge_number} = get_handshake_challenge(q)

        send_packet(q, McQueryEx.BasicStat.create(q, challenge_number))

        {:ok, resp} =  recv_packet(q)
        McQueryEx.BasicStat.decode_response(resp)
    end

    @doc """
    Pulls the full stats from the MC server.

    Returns `McQueryEx.FullStat.t()`

    ## Examples

        iex> query = McQueryEx.new(host: {192, 168, 0, 150}, port: 25565)
        iex> full_stats = McQueryEx.get_full_stat(query)
        %McQueryEx.FullStat{}
    """
    @spec get_full_stat(__MODULE__.t()) :: McQueryEx.FullStat.t()
    def get_full_stat(q = %__MODULE__{}) do
      {:ok, challenge_number} = get_handshake_challenge(q)
      send_packet(q, McQueryEx.FullStat.create(q, challenge_number))
      {:ok, resp} =  recv_packet(q)
      McQueryEx.FullStat.decode_response(resp)
    end

    @doc false
    defp get_handshake_challenge(q = %__MODULE__{}) do
      send_packet(q, McQueryEx.Handshake.create(q))

      {:ok, resp} = recv_packet(q)

      McQueryEx.Handshake.decode_response(resp)
    end

    @doc false
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

    @doc false
    defp send_packet(_q = %__MODULE__{socket: socket, host: host, port: port}, packet) do
      :gen_udp.send(socket, host, port, packet)
    end
end
