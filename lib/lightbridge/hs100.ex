defmodule Lightbridge.Hs100 do
  @moduledoc """
  Handles the commands to the Hs100.
  """

  use Bitwise

  # Static key to work from
  # SEE:https://www.softscheck.com/en/reverse-engineering-tp-link-hs110/#TP-Link%20Device%20Debug%20Protocol
  @encryption_key 0xAB

  @doc """
  Gets the time from the switch.
  """
  @spec get_time :: nil
  def get_time() do
    ~s({"time":{"get_time":null}})
    |> send_cmd()
  end

  @doc """
  Gets the info from the switch.
  """
  @spec get_sysinfo :: nil
  def get_sysinfo() do
    ~s({"system":{"get_sysinfo":null}})
    |> send_cmd()
  end

  @doc """
  Gets the current energy usage of the switch.
  """
  @spec get_energy :: nil
  def get_energy() do
    ~s({"emeter":{"get_realtime":{}}})
    |> send_cmd()
  end

  @doc """
  Turns on the relay.
  """
  @spec turn_on :: nil
  def turn_on() do
    ~s({"system":{"set_relay_state":{"state":1}}})
    |> send_cmd()
  end

  @doc """
  Turns off the relay.
  """
  @spec turn_off :: nil
  def turn_off() do
    ~s({"system":{"set_relay_state":{"state":0}}})
    |> send_cmd()
  end

  # TODO: Add proper return from a relay switch
  @doc """
  Sends the `cmd` to the HS100/110.
  """
  @spec send_cmd(cmd :: String.t()) :: binary()
  def send_cmd(cmd) do
    encrypted =
      cmd
      |> encrypt()

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
  @spec encrypt(cmd :: String.t()) :: list()
  def encrypt(cmd) do
    # Encode the length as a uint32
    ciphertext = [0, 0, 0, byte_size(cmd)]

    # Build the payload
    payload = do_encrypt_payload(cmd, _accm = [], @encryption_key)

    # Append the encrypted payload to the ciphertext
    ciphertext ++ payload
  end

  defp do_encrypt_payload(<<>>, accm, _key), do: accm

  defp do_encrypt_payload(<<byte, rest::binary>>, accm, key) do
    slam = bxor(key, byte)
    do_encrypt_payload(rest, accm ++ [slam], slam)
  end

  @doc """
  Handles decrypting commands from HS100.
  """
  @spec decrypt(ciphertext :: binary()) :: String.t()
  def decrypt(ciphertext) do
    # Ignore the first 4 bytes as that's the length of the ciphertext (uint32)
    <<_, _, _, _, rest::binary>> = ciphertext

    # Recursively build the payload
    do_decrypt_payload(rest, _accm = [], @encryption_key)
  end

  defp do_decrypt_payload(<<>>, accm, _key), do: accm

  defp do_decrypt_payload(<<byte, rest::binary>>, accm, key) do
    next_key = byte
    slam = bxor(key, byte)
    do_decrypt_payload(rest, accm ++ [slam], next_key)
  end

  defp hs100_ip() do
    Application.fetch_env!(:lightbridge, :hs100_ip)
  end
end
