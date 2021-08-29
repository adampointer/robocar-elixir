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
  Return the path to the sysfs directory for the given PWM struct

  ## Examples

      iex> RoboCar.PWM.new |> RoboCar.PWM.sysfs_path
      "/tmp/sys/class/pwm/pwmchip0/pwm0"

  """
  @spec sysfs_path(%PWM{chip_num: integer, channel_num: integer}) :: String
  def sysfs_path(pwm) do
    Path.join([
      Application.fetch_env!(:robocar, :sysfs_root_path),
      "pwmchip#{pwm.chip_num}",
      "pwm#{pwm.channel_num}"
    ])
  end

  @doc ~S"""
  Return the path to the sysfs pwm enable file for the given PWM struct

  ## Examples

      iex> RoboCar.PWM.new |> RoboCar.PWM.enable_path
      "/tmp/sys/class/pwm/pwmchip0/pwm0/enable"

  """
  @spec enable_path(%PWM{chip_num: integer, channel_num: integer}) :: String
  def enable_path(pwm) do
    pwm
    |> sysfs_path()
    |> Path.join("enable")
  end

  @doc ~S"""
  Return the path to the sysfs pwm duty_cycle file for the given PWM struct

  ## Examples

      iex> RoboCar.PWM.new |> RoboCar.PWM.duty_cycle_path
      "/tmp/sys/class/pwm/pwmchip0/pwm0/duty_cycle"

  """
  @spec duty_cycle_path(%PWM{chip_num: integer, channel_num: integer}) :: String
  def duty_cycle_path(pwm) do
    pwm
    |> sysfs_path()
    |> Path.join("duty_cycle")
  end

  @doc ~S"""
  Return the path to the sysfs pwm period file for the given PWM struct

  ## Examples

      iex> RoboCar.PWM.new |> RoboCar.PWM.period_path
      "/tmp/sys/class/pwm/pwmchip0/pwm0/period"

  """
  @spec period_path(%PWM{chip_num: integer, channel_num: integer}) :: String
  def period_path(pwm) do
    pwm
    |> sysfs_path()
    |> Path.join("period")
  end

  @doc ~S"""
  Enable PWM channel

  ## Examples

      iex> RoboCar.PWM.new |> RoboCar.PWM.enable
      :ok

  """
  @spec enable(%PWM{chip_num: integer, channel_num: integer}) :: :ok | {:error, term}
  def enable(pwm) do
    pwm
    |> enable_path()
    |> File.open!([:write])
    |> IO.binwrite("1")
  end
end
