defmodule Lightbridge.Config do
  @moduledoc """
  Config handles pulling out the configuration options
  """

  @doc """
  Gets the config under the `key`.
  """
  @spec fetch(key :: atom()) :: any()
  def fetch(key) do
    case Application.fetch_env(:lightbridge, key) do
      {:ok, val} ->
        val

      _ ->
        raise ArgumentError, "Missing `#{inspect(key)}` from application config"
    end
  end
end
