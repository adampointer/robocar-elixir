defmodule RoboCar.Native.NifBridge do
  use Rustler, otp_app: :robocar, crate: "robocar_hardware"

  def new(), do: :erlang.nif_error(:not_not_loaded)

  def forwards(_drive, _power_pct), do: :erlang.nif_error(:not_not_loaded)

  def reverse(_drive, _power_pct), do: :erlang.nif_error(:not_not_loaded)

  def stop(_drive), do: :erlang.nif_error(:not_not_loaded)
end
