defmodule Lightbridge.MqttHandler do
  @moduledoc """
  Implements `Tortoise.Handler` behaviour.
  """

  require Logger

  alias Lightbridge.Hs100

  @behaviour Tortoise.Handler

  def init(_args) do
    {:ok, nil}
  end

  def connection(status, state) do
    Logger.warn("Connection status: #{inspect(status)}")
    {:ok, state}
  end

  def subscription(status, topic_filter, state) do
    Logger.info("#{topic_filter}, #{status}")
    {:ok, state}
  end

  def terminate(reason, _state) do
    Logger.info(inspect(reason))
  end

  # Message handlers

  def handle_message(_topic, _payload = "0", state) do
    Logger.info("Turning light off")
    Hs100.turn_off()
    {:ok, state}
  end

  def handle_message(_topic, _payload = "1", state) do
    Logger.info("Turning light on")
    Hs100.turn_on()
    {:ok, state}
  end

  def handle_message(topic, payload, state) do
    Logger.info("#{topic}, #{payload}")

    {:ok, state}
  end
end
