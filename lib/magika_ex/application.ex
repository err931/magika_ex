defmodule MagikaEx.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {MagikaEx, name: MagikaEx}
    ]

    opts = [strategy: :one_for_one, name: MagikaEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
