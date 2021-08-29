defmodule RoboCar.PWMTest do
  use ExUnit.Case
  doctest RoboCar.PWM

  setup_all do
    Application.fetch_env!(
      :robocar,
      :sysfs_root_path
    )
    |> Path.join("pwmchip0/pwm0")
    |> File.mkdir_p!()
  end
end
