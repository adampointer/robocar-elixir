defmodule RoboCar.Pins do
  defmacro left_pwm do
    quote do: 32
  end

  defmacro right_pwm do
    quote do: 33
  end

  defmacro left_motor_direction_a do
    quote do: 36
  end

  defmacro right_motor_direction_a do
    quote do: 35
  end

  defmacro left_motor_direction_b do
    quote do: 38
  end

  defmacro right_motor_direction_b do
    quote do: 37
  end

  defmacro sonar_trigger do
    quote do: 7
  end

  defmacro sonar_listen do
    quote do: 11
  end
end
