defmodule McQueryEx.Handshake do
    def create(%McQueryEx{session_id: id}) do
        <<
            McQueryEx.get_magic()::big-integer-16,
            9::big-integer-8,
            id::big-integer-32
            #empty payload.
        >>
    end

    def decode_response(<<9::big-integer-8, _session_id::big-integer-32, challenge::binary>>) do
        {parsed_challenge, _rem} = Integer.parse(challenge)
        {:ok, parsed_challenge}
    end

    def decode_response(_incorrect_response) do
        {:error, "Handshake response was malformed."}
    end
end