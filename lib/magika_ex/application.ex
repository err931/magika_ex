defmodule MagikaEx.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    {:ok, resource} = MagikaEx.Native.new()
    :persistent_term.put({MagikaEx, :resource}, resource)

    Supervisor.start_link([], strategy: :one_for_one, name: MagikaEx.Supervisor)
  end
end
