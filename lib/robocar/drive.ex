defmodule RoboCar.Drive do
  use GenServer

  alias RoboCar.Native.NifBridge

  def start() do
    GenServer.start_link(__MODULE__, :ok, name: DriveSystem)
  end

  def forwards(power_pct) do
    GenServer.cast(DriveSystem, {:forwards, power_pct})
  end

  def reverse(power_pct) do
    GenServer.cast(DriveSystem, {:reverse, power_pct})
  end

  def stop() do
    GenServer.cast(DriveSystem, :stop)
  end

  @impl true
  def init(_arg) do
    case NifBridge.new_drive_system do
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
  def handle_cast(:stop, resource) do
    case NifBridge.stop(resource) do
      {:ok, _} -> {:noreply, resource}
      {:error, reason} -> {:stop, reason, {}}
    end
  end

  @impl true
  def terminate(_reason, _drive) do

  end
end
