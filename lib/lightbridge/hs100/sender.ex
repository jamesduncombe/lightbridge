defmodule Lightbridge.Hs100.Sender do
  @moduledoc """
  Define the sender behaviour.
  """

  @type hs100_command :: String.t()

  # TODO: Add proper return from a relay switch
  @callback send_cmd(hs100_command()) :: {atom(), any()}
end
