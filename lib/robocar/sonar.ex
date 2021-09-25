defmodule RoboCar.Sonar do
  use GenServer

  alias RoboCar.Native.NifBridge

  @pubsub_topic "sonar"
  @ping_interval_ms 500
  @turning_duration_ms 2000

  def topic, do: @pubsub_topic

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: Sonar)
  end

  @impl true
  def init(_arg) do
    case NifBridge.new_sensor_system() do
      {:ok, resource} ->
        schedule_ping()
        {:ok, resource}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_info(:ping, resource) do
    case NifBridge.poll_distance(resource) do
      {:ok, distance} ->
        detect_collision(distance)
        {:noreply, resource}

      {:error, reason} ->
        {:stop, reason, {}}
    end
  end

  def handle_info(:forwards, _resource) do
    Phoenix.PubSub.broadcast(RoboCar.PubSub, RoboCar.Drive.topic(), :forwards)
    schedule_ping()
  end

  defp detect_collision(distance) when distance < 10 do
    Phoenix.PubSub.broadcast(RoboCar.PubSub, RoboCar.Drive.topic(), :left)
    Process.send_after(self(), :forwards, @turning_duration_ms)
  end

  defp detect_collision(distance) when distance >= 10 do
    broadcast(distance)
    schedule_ping()
  end

  defp schedule_ping do
    Process.send_after(self(), :ping, @ping_interval_ms)
  end

  defp broadcast(distance) do
    Phoenix.PubSub.broadcast(RoboCar.PubSub, topic(), {:distance, distance})
  end
end
