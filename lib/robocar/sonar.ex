defmodule RoboCar.Sonar do
  use GenServer

  alias RoboCar.Native.NifBridge

  @pubsub_topic "sonar"
  @ping_interval_ms 500

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: Sonar)
  end

  @impl true
  def init(_arg) do
    case NifBridge.new_sensor_system() do
      {:ok, resource} ->
        schedule_work()
        {:ok, resource}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_info(:ping, resource) do
    case NifBridge.poll_distance(resource) do
      {:ok, distance} ->
        broadcast(distance)
        schedule_work()
        {:noreply, resource}

      {:error, reason} ->
        {:stop, reason, {}}
    end
  end

  def topic, do: @pubsub_topic

  defp schedule_work do
    Process.send_after(self(), :ping, @ping_interval_ms)
  end

  defp broadcast(distance) do
    Phoenix.PubSub.broadcast(RoboCar.PubSub, topic(), {:distance, distance})
  end
end
