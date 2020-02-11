defmodule McQueryEx.Queryer do
  use GenServer
  require Logger
  defstruct socket: nil, host: {127, 0, 0, 1}, port: 25565, session_id: 0, timeout: 1000, challenge: 0

  def start_link(args) when is_list(args) do
    IO.inspect args
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    IO.inspect args
    u = :gen_udp.open(0, [:binary, active: false])
    IO.inspect u

    case u do
      {:ok, socket} ->  {:ok, %__MODULE__{socket: socket, host: args[:host], port: args[:port]}}
      {:error, reason} -> {:stop, reason}
    end
    |> IO.inspect
  end

  def get_basic_stats() do
    GenServer.call(__MODULE__, :get_basic_stats)
  end

  @impl true
  def handle_call(:get_basic_stats, _from, state) do
    state = get_challenge(state)
    :gen_udp.send(state.socket, state.host, state.port, <<0xFE, 0xFD, 0, state.session_id::big-integer-32, state.challenge::big-integer-32>>)
    |> IO.inspect

    stats =
    case :gen_udp.recv(state.socket, 1024, state.timeout) do
      {:ok, resp} -> resp
      {:error, reason} -> reason
    end

    {:reply, stats, state}
  end

  defp get_challenge(state) do
    Logger.info "[get_challenge] Sending Challenge Request"
    :gen_udp.send(state.socket, state.host, state.port, <<0xFE, 0xFD, 0x09, state.session_id::big-integer-32>>)

    host = state.host
    port = state.port

    Logger.info "[get_challenge] Getting Response."
    case :gen_udp.recv(state.socket, 1024, state.timeout) do
      {:ok, {^host, ^port, resp}} ->
        Logger.info "[get_challenge] Processing Responce"
        case parse_challenge(resp, state.session_id) do
          {:ok, decoded_challenge} ->
            Logger.info "[get_challenge] Challenge acquired!"
            %{state | challenge: decoded_challenge}
          {:error, reason} ->
            Logger.warn reason
            state
        end
      {:error, reason} ->
        Logger.warn reason
        state
    end
  end

  defp parse_challenge(<<9::big-integer-8, session_id::big-integer-32, challenge::binary>>, our_session_id) do
    if session_id == our_session_id do
      {parsed_challenge, _rem} = Integer.parse(challenge)
      {:ok, parsed_challenge}
    else
      {:error, "Challenge session did not match our session."}
    end
  end

  defp parse_challenge(resp, _our_session_id) do
    IO.inspect resp
    {:error, "Unknown challenge resp."}
  end
end
