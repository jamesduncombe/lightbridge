defmodule Lightbridge.Hs100.MockSender do
  @moduledoc """
  Simply echos whatever command it receives for testing.
  """

  @behaviour Lightbridge.Hs100.Sender

  def send_cmd(cmd) do
    {:notencrypted, cmd}
  end
end
