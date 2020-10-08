defmodule Lightbridge.Hs100.TcpSender do
  @moduledoc """
  Sends requests to the HS100/110 over the network.
  """

  @behaviour Lightbridge.Hs100.Sender

  def send_cmd(cmd) do
    {:ok, sock} =
      :gen_tcp.connect(hs100_ip(), _port = 9999, [:binary, {:packet, 0}, {:active, false}])

    :ok = :gen_tcp.send(sock, cmd)
    {:ok, data} = :gen_tcp.recv(sock, _all_please = 0)
    :ok = :gen_tcp.close(sock)

    {:encrypted, data}
  end

  defp hs100_ip() do
    Application.fetch_env!(:lightbridge, :hs100_ip)
  end
end
