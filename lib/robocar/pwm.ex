defmodule RoboCar.PWM do
  defstruct chip_num: 0, channel_num: 0

  alias RoboCar.PWM

  def new(chip_num, channel_num),
    do: %PWM{chip_num: chip_num, channel_num: channel_num} |> maybe_export!

  def new(), do: %PWM{} |> maybe_export!

  def disable(pwm), do: write_to_enable(pwm, "0")

  def enable(pwm), do: write_to_enable(pwm, "1")

  def configure(pwm, freq_hz, power_pct) do
    period = 1_000_000_000 / freq_hz
    duty_cycle = period * (power_pct / 100)

    with :ok <- write_to_period(pwm, period), :ok <- write_to_duty_cycle(pwm, duty_cycle) do
      {:ok, pwm}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def configure!(pwm, freq_hz, power_pct) do
    case configure(pwm, freq_hz, power_pct) do
      {:ok, pwm} -> pwm
      {:error, reason} -> raise "Write failed with #{Atom.to_string(reason)}"
    end
  end

  def clean_up(pwm) do
    pwm |> configure!(0, 0) |> disable()

    unexport(pwm)
  end

  defp maybe_export!(pwm) do
    if pwm |> pwm_channel_path |> File.exists?() do
      pwm
    else
      export!(pwm)
    end
  end

  defp export!(pwm) do
    case pwm |> export_path() |> write_to_file(Integer.to_string(pwm.channel_num)) do
      :ok -> pwm
      {:error, reason} -> raise "Export failed with #{Atom.to_string(reason)}"
    end
  end

  defp unexport(pwm) do
    pwm
    |> unexport_path()
    |> write_to_file(Integer.to_string(pwm.channel_num))
  end

  defp export_path(pwm), do: Path.join([sysfs_path(pwm), "export"])

  defp unexport_path(pwm), do: Path.join([sysfs_path(pwm), "unexport"])

  defp pwm_channel_path(pwm), do: Path.join([sysfs_path(pwm), "pwm#{pwm.channel_num}"])

  defp sysfs_path(pwm) do
    Path.join([Application.fetch_env!(:robocar, :sysfs_root_path), "pwmchip#{pwm.chip_num}"])
  end

  defp enable_path(pwm), do: pwm |> pwm_channel_path() |> Path.join("enable")

  defp duty_cycle_path(pwm), do: pwm |> pwm_channel_path() |> Path.join("duty_cycle")

  defp period_path(pwm), do: pwm |> pwm_channel_path() |> Path.join("period")

  defp write_to_duty_cycle(pwm, val), do: pwm |> duty_cycle_path() |> write_to_file(val)

  defp write_to_period(pwm, val), do: pwm |> period_path() |> write_to_file(val)

  defp write_to_enable(pwm, val), do: pwm |> enable_path() |> write_to_file(val)

  defp write_to_file(path, val) when is_float(val) do
    path
    |> File.open!([:write])
    |> IO.binwrite(:erlang.float_to_binary(val, decimals: 0))
  end

  defp write_to_file(path, val) when is_binary(val) do
    path
    |> File.open!([:write])
    |> IO.binwrite(val)
  end
end
