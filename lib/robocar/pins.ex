defmodule RoboCar.Pins do
  defmacro left_motor_direction_a do
    quote do: 51
  end

  defmacro right_motor_direction_a do
    quote do: 76
  end

  defmacro left_motor_direction_b do
    quote do: 77
  end

  defmacro right_motor_direction_b do
    quote do: 12
  end

  defmacro sonar_trigger do
    quote do: 216
  end

  defmacro sonar_listen do
    quote do: 50
  end
end
