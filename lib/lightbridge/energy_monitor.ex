defmodule Lightbridge.EnergyMonitor do
  @moduledoc """
  Polls the smart socket to get it's current energy usage.

  Publishes to configured MQTT endpoint.
  """

  use GenServer

  import Lightbridge.Config, only: [fetch: 1]

  alias Lightbridge.Hs100
  alias Lightbridge.EnergyMonitor.Stats

  # Set the polling frequency for energy stats
  @poll_frequency 15 * 1_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_args) do
    Process.send_after(self(), :poll, @poll_frequency)
    {:ok, %{client_id: fetch(:mqtt_client_id), energy_topic: fetch(:mqtt_energy_topic)}}
  end

  @doc """
  Polls the energy stats then sends them up to the MQTT broker.
  """
  @spec poll(client_id :: String.t(), energy_topic :: String.t()) :: any()
  def poll(client_id, energy_topic) do
    # Get the energy stats
    # Parse them into a suitable structure
    # Batch them up into async tasks
    # TODO: This seems quite tightly coupled together...
    tasks =
      Hs100.get_energy()
      |> parse_energy_stats()
      |> Map.from_struct()
      |> Enum.map(fn {path, stat} ->
        Task.async(
          Tortoise,
          :publish,
          [client_id, "#{energy_topic}/#{path}", to_string(stat), [qos: 0]]
        )
      end)

    # Asyncly fire these off to the MQTT server
    Task.await_many(tasks, _wait_for = 2_000)
  end

  def handle_info(:poll, %{client_id: client_id, energy_topic: energy_topic} = state) do
    poll(client_id, energy_topic)

    # Poll ourselves in `@poll_frequency` seconds
    Process.send_after(self(), :poll, @poll_frequency)
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
      |> Jason.decode(keys: :atoms)

    # Get the stats from the nested structure
    parsed_energy_stats
    |> get_in([:emeter, :get_realtime])
    |> Stats.new()
  end

  defmodule Stats do
    @moduledoc """
    Stats encapsulates the data coming back from the smart socket.
    """
    defstruct current_ma: 0, err_code: 0, power_mw: 0, total_wh: 0, voltage_mv: 0

    @typedoc """
    Represents the Stats struct.
    """
    @type t :: %__MODULE__{
            current_ma: pos_integer(),
            err_code: integer(),
            power_mw: pos_integer(),
            total_wh: pos_integer(),
            voltage_mv: pos_integer()
          }

    @doc """
    Takes in a map of energy stats and returns a new `t()`.
    """
    @spec new(energy_stats :: map()) :: t()
    def new(energy_stats) do
      struct(__MODULE__, energy_stats)
    end
  end

  defimpl String.Chars, for: Stats do
    def to_string(energy_stats) do
      ~s"""
      Power (mW): #{energy_stats.power_mw}
      Voltage (mV): #{energy_stats.voltage_mv}
      Current (mA): #{energy_stats.current_ma}
      Total WH: #{energy_stats.total_wh}
      """
    end
  end
end
