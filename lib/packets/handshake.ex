defmodule McQueryEx.Handshake do
    @moduledoc """
    McQueryEx.Handshake creates Handshake requests, and decodes Handshake responses. Used internally with each request.
    """
    @type t :: <<_::56>>

    @spec create(McQueryEx.t()) :: __MODULE__.t()
    def create(%McQueryEx{session_id: id}) do
        <<
            McQueryEx.get_magic()::big-integer-16,
            9::big-integer-8,
            id::big-integer-32
            #empty payload.
        >>
    end
    
    @spec decode_response(binary()) :: {:ok, integer}
    def decode_response(<<9::big-integer-8, _session_id::big-integer-32, challenge::binary>>) do
        {parsed_challenge, _rem} = Integer.parse(challenge)
        {:ok, parsed_challenge}
    end

    @spec decode_response(any()) :: {:error, String.t()}
    def decode_response(_incorrect_response) do
        {:error, "Handshake response was malformed."}
    end
end