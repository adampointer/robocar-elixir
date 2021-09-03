defmodule RoboCar.GPIO do
  def pin_mode(pin, :output) when pin > 0 do
    pin
    |> export
    |> pin_direction_path
    |> write_to_file("out")

    pin |> digital_write(:low)
  end

  def pin_mode(pin, :input) when pin > 0 do
    pin
    |> export
    |> pin_direction_path
    |> write_to_file("in")
  end

  def pin_release(pin) when pin > 0 do
    contents = Integer.to_string(pin)
    write_to_file("/sys/class/gpio/unexport", contents)
  end

  def digital_write(pin, :high) when pin > 0 do
    pin |> pin_value_path() |> write_to_file("1")
  end

  def digital_write(pin, :low) when pin > 0 do
    pin |> pin_value_path() |> write_to_file("0")
  end

  def digital_read(pin) when pin > 0 do
    pin
    |> pin_value_path
    |> read_from_file(1)
    |> handle_input_result
  end

  defp handle_input_result("0"), do: :low
  defp handle_input_result("1"), do: :high

  defp export(pin) do
    write_to_file("/sys/class/gpio/export", Integer.to_string(pin))
    pin
  end

  defp pin_direction_path(pin), do: pin |> pin_path() |> Path.join("direction")

  defp pin_value_path(pin), do: pin |> pin_path() |> Path.join("value")

  defp pin_path(pin), do: "/sys/class/gpio/gpio" <> Integer.to_string(pin)

  defp write_to_file(file_path, contents) do
    case file_path |> File.open([:write]) do
      {:ok, file} ->
        IO.binwrite(file, contents)

      {:error, :eacces} ->
        :timer.sleep(10)
        write_to_file(file_path, contents)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp read_from_file(file_path, length) do
    File.open!(file_path, [:read], fn file ->
      IO.binread(file, length)
    end)
  end
end
