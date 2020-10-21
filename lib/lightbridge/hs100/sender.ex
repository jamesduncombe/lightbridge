defmodule Lightbridge.Hs100.Sender do
  @moduledoc """
  Define the sender behaviour.
  """

  @type hs100_command :: String.t()

  # TODO: Add proper return from a relay switch
  @doc """
  Sends a command to the HS100/110.
  """
  @callback send_cmd(hs100_command()) :: {atom(), any()}

  defmacro __using__(_opts) do
    quote do
      adapter = Application.get_env(:lightbridge, :sender_implementation, nil)

      unless adapter do
        raise ArgumentError, "missing :sender_implementation key in config"
      end

      @adapter adapter
    end
  end
end
