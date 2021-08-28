defmodule RoboCar.PWM do
  defstruct chip_num: 0, channel_num: 1

  alias RoboCar.PWM

  def new(chip_num, channel_num) do
    %PWM{chip_num: chip_num, channel_num: channel_num}
  end

  def new() do
    %PWM{}
  end

  def sysfs_path(%PWM{} = pwm) do
    Path.join(["/", "sys", "class", "pwm", "pwmchip#{pwm.chip_num}", "pwm#{pwm.channel_num}"])
  end

  def enable_path(%PWM{} = pwm) do
    pwm
    |> sysfs_path()
    |> Path.join("enable")
  end

  def duty_cycle_path(%PWM{} = pwm) do
    pwm
    |> sysfs_path()
    |> Path.join("duty_cycle")
  end

  def period_path(%PWM{} = pwm) do
    pwm
    |> sysfs_path()
    |> Path.join("period")
  end

  def enable(%PWM{} = pwm) do
    pwm
    |> enable_path()
    |> File.open!([:write])
    |> IO.binwrite("1")
  end
end
