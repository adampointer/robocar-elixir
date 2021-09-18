defmodule RoboCarWeb.Sonar do
  use RoboCarWeb, :live_view

  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(RoboCar.PubSub, RoboCar.Sonar.topic())
    {:ok, assign(socket, query: "", distance: 0)}
  end

  @impl true
  def handle_info({:distance, d}, socket) do
    {:noreply, assign(socket, distance: d)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <h1>The distance is: <%= @distance %></h1>
    </div>
    """
  end
end
