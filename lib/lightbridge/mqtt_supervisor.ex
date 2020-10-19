defmodule Lightbridge.MqttSupervisor do
  @moduledoc """
  Handles connection to MQTT broker.
  """

  use Supervisor

  alias Lightbridge.MqttHandler

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_args) do
    children = [
      {Tortoise.Connection,
       [
         client_id: mqtt_client_id(),
         user_name: mqtt_username(),
         password: mqtt_password(),
         server: {Tortoise.Transport.Tcp, host: mqtt_host(), port: mqtt_port()},
         handler: {MqttHandler, []},
         subscriptions: [{mqtt_topic(), _qos = 0}]
       ]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  # Get config

  defp mqtt_client_id() do
    Application.fetch_env!(:lightbridge, :mqtt_client_id)
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
