defmodule Lightbridge.Hs100 do
  @moduledoc """
  Handles both the available commands to the HS100/110 and encryption/decryption.
  """

  use Bitwise

  # Static key to work from
  # SEE:https://www.softscheck.com/en/reverse-engineering-tp-link-hs110/#TP-Link%20Device%20Debug%20Protocol
  @encryption_key 0xAB

  # Adapter to use to send
  use Lightbridge.Transport

  @doc """
  Gets the time from the switch.
  """
  @spec get_time :: String.t()
  def get_time() do
    ~s({"time":{"get_time":null}})
    |> send_cmd()
  end

  @doc """
  Gets the info from the switch.
  """
  @spec get_sysinfo :: String.t()
  def get_sysinfo() do
    ~s({"system":{"get_sysinfo":null}})
    |> send_cmd()
  end

  @doc """
  Gets the current energy usage of the switch.
  """
  @spec get_energy :: String.t()
  def get_energy() do
    ~s({"emeter":{"get_realtime":{}}})
    |> send_cmd()
  end

  @doc """
  Turns on the relay.
  """
  @spec turn_on :: String.t()
  def turn_on() do
    ~s({"system":{"set_relay_state":{"state":1}}})
    |> send_cmd()
  end

  @doc """
  Turns off the relay.
  """
  @spec turn_off :: String.t()
  def turn_off() do
    ~s({"system":{"set_relay_state":{"state":0}}})
    |> send_cmd()
  end

  @doc """
  Sends the `cmd` to the HS100/110.
  """
  @spec send_cmd(cmd :: String.t()) :: String.t()
  def send_cmd(cmd) do
    cmd
    |> encrypt()
    |> @adapter.send_cmd()
    |> @adapter.process_response()
  end

  @doc """
  Handles encrypting commands.
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
    xord_val = bxor(key, byte)
    do_encrypt_payload(rest, accm ++ [xord_val], xord_val)
  end

  @doc """
  Handles decrypting commands.
  """
  @spec decrypt(ciphertext :: String.t()) :: String.t()
  def decrypt(ciphertext) do
    # Ignore the first 4 bytes as that's the length of the ciphertext (uint32)
    <<_, _, _, _, rest::binary>> = ciphertext

    # Recursively build the payload
    do_decrypt_payload(rest, _accm = [], @encryption_key)
  end

  defp do_decrypt_payload(<<>>, accm, _key), do: to_string(accm)

  defp do_decrypt_payload(<<byte, rest::binary>>, accm, key) do
    next_key = byte
    xord_val = bxor(key, byte)
    do_decrypt_payload(rest, accm ++ [xord_val], next_key)
  end
end
