defmodule Lightbridge.MqttSupervisor do
  @moduledoc """
  Handles connection to MQTT broker.
  """

  use Supervisor

  alias Lightbridge.MqttHandler

  import Lightbridge.Config, only: [fetch: 1]

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_args) do
    children = [
      {Tortoise.Connection,
       [
         client_id: fetch(:mqtt_client_id),
         user_name: fetch(:mqtt_username),
         password: fetch(:mqtt_password),
         server: {Tortoise.Transport.Tcp, host: fetch(:mqtt_host), port: fetch(:mqtt_port)},
         handler: {MqttHandler, []},
         subscriptions: [{fetch(:mqtt_topic), _qos = 0}]
       ]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
