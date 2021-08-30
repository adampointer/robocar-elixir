defmodule RoboCar.PWM do
  @moduledoc ~S"""
  Control the hardware PWM via the sysfs interface
  """

  defstruct chip_num: 0, channel_num: 0

  alias RoboCar.PWM

  @doc ~S"""
  Create a new `%RoboCar.PWM{chip_num: chip_num, channel_num: channel_num}` struct 

  ## Examples

      iex> RoboCar.PWM.new(1, 1)
      %RoboCar.PWM{channel_num: 1, chip_num: 1}

  """
  @spec new(integer, integer) :: %PWM{chip_num: integer, channel_num: integer}
  def new(chip_num, channel_num) do
    %PWM{chip_num: chip_num, channel_num: channel_num}
  end

  @doc ~S"""
  Create a new `%RoboCar.PWM{}` struct with default values

  ## Examples

      iex> RoboCar.PWM.new
      %RoboCar.PWM{channel_num: 0, chip_num: 0}

  """
  @spec new() :: %PWM{chip_num: integer, channel_num: integer}
  def new() do
    %PWM{}
  end

  @doc ~S"""
  Disable PWM channel

  ## Examples

      iex> RoboCar.PWM.new |> RoboCar.PWM.disable
      :ok

  """
  @spec disable(%PWM{chip_num: integer, channel_num: integer}) :: :ok | {:error, term}
  def disable(pwm) do
    write_to_enable(pwm, "0")
  end

  @doc ~S"""
  Enable PWM channel

  ## Examples

      iex> RoboCar.PWM.new |> RoboCar.PWM.enable
      :ok

  """
  @spec enable(%PWM{chip_num: integer, channel_num: integer}) :: :ok | {:error, term}
  def enable(pwm) do
    write_to_enable(pwm, "1")
  end

  @spec configure(%PWM{chip_num: integer, channel_num: integer}, integer, integer) ::
          {:ok, %PWM{chip_num: integer, channel_num: integer}} | {:error, term}
  def configure(pwm, freq_hz, power_pct) do
    period = 1_000_000_000 / freq_hz
    duty_cycle = period * (power_pct / 100)

    with :ok <- write_to_period(pwm, period), :ok <- write_to_duty_cycle(pwm, duty_cycle) do
      {:ok, pwm}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec configure!(%PWM{chip_num: integer, channel_num: integer}, integer, integer) ::
          %PWM{chip_num: integer, channel_num: integer}
  def configure!(pwm, freq_hz, power_pct) do
    case configure(pwm, freq_hz, power_pct) do
      {:ok, pwm} -> pwm
      {:error, reason} -> raise "Write failed with #{Atom.to_string(reason)}"
    end
  end

  @spec sysfs_path(%PWM{chip_num: integer, channel_num: integer}) :: String
  defp sysfs_path(pwm) do
    Path.join([
      Application.fetch_env!(:robocar, :sysfs_root_path),
      "pwmchip#{pwm.chip_num}",
      "pwm#{pwm.channel_num}"
    ])
  end

  @spec enable_path(%PWM{chip_num: integer, channel_num: integer}) :: String
  defp enable_path(pwm) do
    pwm
    |> sysfs_path()
    |> Path.join("enable")
  end

  @spec duty_cycle_path(%PWM{chip_num: integer, channel_num: integer}) :: String
  defp duty_cycle_path(pwm) do
    pwm
    |> sysfs_path()
    |> Path.join("duty_cycle")
  end

  @spec period_path(%PWM{chip_num: integer, channel_num: integer}) :: String
  defp period_path(pwm) do
    pwm
    |> sysfs_path()
    |> Path.join("period")
  end

  @spec write_to_duty_cycle(%PWM{chip_num: integer, channel_num: integer}, String) ::
          :ok | {:error, term}
  defp write_to_duty_cycle(pwm, val) do
    pwm
    |> duty_cycle_path()
    |> write_to_file(val)
  end

  @spec write_to_period(%PWM{chip_num: integer, channel_num: integer}, String) ::
          :ok | {:error, term}
  defp write_to_period(pwm, val) do
    pwm
    |> period_path()
    |> write_to_file(val)
  end

  @spec write_to_enable(%PWM{chip_num: integer, channel_num: integer}, String) ::
          :ok | {:error, term}
  defp write_to_enable(pwm, val) do
    pwm
    |> enable_path()
    |> write_to_file(val)
  end

  @spec write_to_file(String, String) :: :ok | {:error, term}
  defp write_to_file(path, val) when is_float(val) do
    path
    |> File.open!([:write])
    |> IO.binwrite(:erlang.float_to_binary(val, decimals: 0))
  end

  @spec write_to_file(String, String) :: :ok | {:error, term}
  defp write_to_file(path, val) when is_binary(val) do
    path
    |> File.open!([:write])
    |> IO.binwrite(val)
  end
end
