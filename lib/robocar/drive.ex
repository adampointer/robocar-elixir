defmodule RoboCar.Drive do
  use GenServer

  defstruct [:left_power, :right_power]

  alias RoboCar.GPIO
  alias RoboCar.Drive
  alias RoboCar.PWM
  import RoboCar.Pins

  @pwm_frequency_hz 1000

  @impl true
  def init(:ok) do
    with :ok = GPIO.pin_mode(left_motor_direction_a(), :output),
         :ok = GPIO.pin_mode(left_motor_direction_b(), :output),
         :ok = GPIO.pin_mode(right_motor_direction_a(), :output),
         :ok = GPIO.pin_mode(right_motor_direction_b(), :output) do
      drive = %Drive{left_power: PWM.new(0, 0), right_power: PWM.new(0, 2)}
      {:ok, drive}
    end
  end

  @impl true
  def handle_cast({:forwards, power_pct}, drive) do
    forwards(drive, power_pct)
  end

  @impl true
  def handle_cast(:stop, drive) do
    stop(drive)
  end

  @impl true
  def terminate(_reason, drive) do
    IO.puts("terminate")
    stop(drive)

    GPIO.pin_release(left_motor_direction_a())
    GPIO.pin_release(left_motor_direction_b())
    GPIO.pin_release(right_motor_direction_a())
    GPIO.pin_release(right_motor_direction_b())
  end

  def forwards(drive, power_pct) do
    PWM.configure!(drive.left_power, @pwm_frequency_hz, power_pct) |> PWM.enable()
    PWM.configure!(drive.right_power, @pwm_frequency_hz, power_pct) |> PWM.enable()

    with :ok = GPIO.digital_write(left_motor_direction_a(), :high),
         :ok = GPIO.digital_write(left_motor_direction_b(), :low),
         :ok = GPIO.digital_write(right_motor_direction_a(), :high),
         :ok = GPIO.digital_write(right_motor_direction_b(), :low) do
      {:noreply, drive}
    end
  end

  def stop(drive) do
    PWM.disable(drive.left_power)
    PWM.disable(drive.right_power)

    with :ok = GPIO.digital_write(left_motor_direction_a(), :low),
         :ok = GPIO.digital_write(left_motor_direction_b(), :low),
         :ok = GPIO.digital_write(right_motor_direction_a(), :low),
         :ok = GPIO.digital_write(right_motor_direction_b(), :low) do
      {:noreply, drive}
    end
  end
end
