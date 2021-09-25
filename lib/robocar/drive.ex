defmodule RoboCar.Drive do
  use GenServer

  alias RoboCar.Native.NifBridge

  @pubsub_topic "drive"

  def topic, do: @pubsub_topic

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, :ok, name: DriveSystem)
  end

  def forwards(power_pct) do
    GenServer.cast(DriveSystem, {:forwards, power_pct})
  end

  def reverse(power_pct) do
    GenServer.cast(DriveSystem, {:reverse, power_pct})
  end

  def right(power_pct) do
    GenServer.cast(DriveSystem, {:right, power_pct})
  end

  def left(power_pct) do
    GenServer.cast(DriveSystem, {:left, power_pct})
  end

  def stop() do
    GenServer.cast(DriveSystem, :stop)
  end

  @impl true
  def init(_arg) do
    Phoenix.PubSub.subscribe(RoboCar.PubSub, topic())

    case NifBridge.new_drive_system() do
      {:ok, resource} -> {:ok, resource}
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl true
  def handle_cast({:forwards, power_pct}, resource) do
    case NifBridge.forwards(resource, power_pct) do
      {:ok, _} -> {:noreply, resource}
      {:error, reason} -> {:stop, reason, {}}
    end
  end

  @impl true
  def handle_cast({:reverse, power_pct}, resource) do
    case NifBridge.reverse(resource, power_pct) do
      {:ok, _} -> {:noreply, resource}
      {:error, reason} -> {:stop, reason, {}}
    end
  end

  @impl true
  def handle_cast({:right, power_pct}, resource) do
    case NifBridge.right(resource, power_pct) do
      {:ok, _} -> {:noreply, resource}
      {:error, reason} -> {:stop, reason, {}}
    end
  end

  @impl true
  def handle_cast({:left, power_pct}, resource) do
    case NifBridge.left(resource, power_pct) do
      {:ok, _} -> {:noreply, resource}
      {:error, reason} -> {:stop, reason, {}}
    end
  end

  @impl true
  def handle_cast(:stop, resource) do
    case NifBridge.stop(resource) do
      {:ok, _} -> {:noreply, resource}
      {:error, reason} -> {:stop, reason, {}}
    end
  end

  @impl true
  def handle_info(:stop, resource) do
    case NifBridge.stop(resource) do
      {:ok, _} -> {:noreply, resource}
      {:error, reason} -> {:stop, reason, {}}
    end
  end

  @impl true
  def handle_info(:start, resource) do
    case NifBridge.forwards(resource, 100) do
      {:ok, _} -> {:noreply, resource}
      {:error, reason} -> {:stop, reason, {}}
    end
  end

  @impl true
  def terminate(_reason, _drive) do
  end
end
