defmodule Lightbridge.Hs100 do
  @moduledoc """
  Handles the commands to the Hs100.
  """

  use Bitwise

  @doc """
  Gets the time from the switch.
  """
  def get_time() do
    ~s({"time":{"get_time":null}})
    |> send_cmd()
  end

  @doc """
  Gets the info from the switch.
  """
  def get_sysinfo() do
    ~s({"system":{"get_sysinfo":null}})
    |> send_cmd()
  end

  @doc """
  Gets the current energy usage of the switch.
  """
  def get_energy() do
    ~s({"emeter":{"get_realtime":{}}})
    |> send_cmd()
  end

  @doc """
  Turns on the relay.
  """
  def turn_on() do
    ~s({"system":{"set_relay_state":{"state":1}}})
    |> send_cmd()
  end

  @doc """
  Turns off the relay.
  """
  def turn_off() do
    ~s({"system":{"set_relay_state":{"state":0}}})
    |> send_cmd()
  end

  # TODO: Add proper return from a relay switch
  def send_cmd(cmd) do
    encrypted = encrypt(cmd)

    {:ok, sock} = :gen_tcp.connect(hs100_ip(), 9999, [:binary, {:packet, 0}, {:active, false}])

    :ok = :gen_tcp.send(sock, encrypted)
    {:ok, data} = :gen_tcp.recv(sock, _all_please = 0)
    :ok = :gen_tcp.close(sock)

    data
    |> decrypt()
  end

  @doc """
  Handles encrypting commands to HS100.
  """
  @spec encrypt(cmd :: String.t()) :: String.t()
  def encrypt(cmd) do
    # Encode the length as a uint32
    x = byte_size(cmd)
    ciphertext = [0, 0, 0, x]

    # Static key to work from
    # SEE:https://www.softscheck.com/en/reverse-engineering-tp-link-hs110/#TP-Link%20Device%20Debug%20Protocol
    key = 0xAB

    # Build the payload
    payload = do_payload(cmd, _accm = [], key)

    # Append the encrypted payload to the ciphertext
    ciphertext ++ payload
  end

  def do_payload(<<>>, accm, key), do: accm

  def do_payload(<<byte, rest::binary>>, accm, key) do
    slam = bxor(key, byte)
    do_payload(rest, accm ++ [slam], slam)
  end

  @doc """
  Handles decrypting commands to HS100.
  """
  def decrypt(ciphertext) do
    # Encode the length as a uint32
    length_of_ciphertext = byte_size(ciphertext)

    # Static key to work from
    # SEE:https://www.softscheck.com/en/reverse-engineering-tp-link-hs110/#TP-Link%20Device%20Debug%20Protocol
    key = 0xAB

    <<_, _, _, _, rest::binary>> = ciphertext

    # Build the payload
    payload = do_decrypt_payload(rest, _accm = [], key)

    # Append the encrypted payload to the ciphertext
    payload
  end

  def do_decrypt_payload(<<>>, accm, key), do: accm

  def do_decrypt_payload(<<byte, rest::binary>>, accm, key) do
    nextKey = byte
    slam = bxor(key, byte)
    do_decrypt_payload(rest, accm ++ [slam], nextKey)
  end

  defp hs100_ip() do
    Application.fetch_env!(:lightbridge, :hs100_ip)
  end
end
