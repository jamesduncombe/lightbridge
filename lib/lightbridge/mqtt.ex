defmodule Lightbridge.Mqtt do
  @moduledoc """
  Handles connection to MQTT broker.
  """

  use GenServer

  alias Lightbridge.MqttHandler

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_args) do
    {ok, pid} =
      Tortoise.Connection.start_link(
        client_id: Hs100,
        user_name: mqtt_username(),
        password: mqtt_password(),
        server: {Tortoise.Transport.Tcp, host: mqtt_host(), port: mqtt_port()},
        handler: {MqttHandler, []}
      )

    Tortoise.Connection.subscribe(Hs100, mqtt_topic(), qos: 0)
    {:ok, pid}
  end

  defp mqtt_username do
    Application.fetch_env!(:lightbridge, :mqtt_username)
  end

  defp mqtt_password do
    Application.fetch_env!(:lightbridge, :mqtt_password)
  end

  defp mqtt_host do
    Application.fetch_env!(:lightbridge, :mqtt_host)
  end

  defp mqtt_port do
    Application.fetch_env!(:lightbridge, :mqtt_port)
  end

  defp mqtt_topic do
    Application.fetch_env!(:lightbridge, :mqtt_topic)
  end
end
