defmodule Lightbridge.EnergyMonitor do
  @moduledoc """
  Polls the smart socket to get it's current energy usage.

  Publishes to configured MQTT endpoint.
  """

  use GenServer

  alias Lightbridge.Hs100

  # Set the polling frequency for energy stats
  @poll_frequency 15 * 1_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_args) do
    Process.send_after(self(), :poll, @poll_frequency)
    {:ok, nil}
  end

  def poll do
    Hs100.get_energy()
    |> parse_energy_stats()
    |> Enum.each(fn {path, stat} ->
      Tortoise.publish(mqtt_client_id(), "#{mqtt_energy_topic()}/#{path}", to_string(stat), qos: 0)
    end)

    # Send back a poll message after `@poll_frequency` seconds
    Process.send_after(self(), :poll, @poll_frequency)
  end

  def handle_info(:poll, state) do
    poll()
    {:noreply, state}
  end

  @doc """
  Takes energy stats and parses them into a flattened map.
  """
  @spec parse_energy_stats(stats :: String.t()) :: map()
  def parse_energy_stats(stats) do
    # Split the values into their own topics
    {:ok, parsed_energy_stats} =
      stats
      |> Jason.decode()

    # Get the stats from the nest structure
    get_in(parsed_energy_stats, ["emeter", "get_realtime"])
  end

  defp mqtt_client_id() do
    Application.fetch_env!(:lightbridge, :mqtt_client_id)
  end

  defp mqtt_energy_topic() do
    Application.fetch_env!(:lightbridge, :mqtt_energy_topic)
  end
end
