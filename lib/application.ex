defmodule McQueryEx.Application do
  use Application

  def start(_type, _args) do
    children = [
      {McQueryEx.Queryer, [host: {192,168,0,20}, port: 25565]}
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
