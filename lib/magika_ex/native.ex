defmodule MagikaEx.Native do
  @moduledoc false

  use Rustler, otp_app: :magika_ex, crate: "magika_nif"

  def new, do: :erlang.nif_error(:nif_not_loaded)
  def identify_bytes(_resource, _data), do: :erlang.nif_error(:nif_not_loaded)
end
