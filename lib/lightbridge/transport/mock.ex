defmodule Lightbridge.Transport.Mock do
  @moduledoc """
  Simply echos whatever command it receives for testing.
  """

  @behaviour Lightbridge.Transport

  @impl true
  def send_cmd(cmd) do
    cmd
  end

  @impl true
  def process_response(response) do
    response
  end
end
