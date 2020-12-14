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

  @commands [
    {:get_time, ~s({"time":{"get_time":null}}), "Gets the time"},
    {:get_sysinfo, ~s({"system":{"get_sysinfo":null}}), "Gets the system info"},
    {:get_energy, ~s({"emeter":{"get_realtime":{}}}), "Gets the current energy usage"},
    {:turn_on, ~s({"system":{"set_relay_state":{"state":1}}}), "Turns on the switch"},
    {:turn_off, ~s({"system":{"set_relay_state":{"state":0}}}), "Turns off the switch"}
  ]

  for {command, payload, what_it_does} <- @commands do
    Module.put_attribute(
      __MODULE__,
      :doc,
      {__ENV__.line(), "#{what_it_does}."}
    )

    def unquote(command)(), do: unquote(payload) |> send_cmd()
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
    slam = bxor(key, byte)
    do_encrypt_payload(rest, accm ++ [slam], slam)
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
    slam = bxor(key, byte)
    do_decrypt_payload(rest, accm ++ [slam], next_key)
  end
end
