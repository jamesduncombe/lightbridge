defmodule Lightbridge.EnergyMonitorTest do
  use ExUnit.Case

  alias Lightbridge.EnergyMonitor

  describe "parse_energy_stats/1" do
    test "parses energy stats from the socket into a flattened map" do
      raw_json =
        "{\"emeter\":{\"get_realtime\":{\"voltage_mv\":246486,\"current_ma\":46,\"power_mw\":5715,\"total_wh\":1958,\"err_code\":0}}}"

      parsed_stats =
        raw_json
        |> EnergyMonitor.parse_energy_stats()

      assert parsed_stats["current_ma"] == 46
      assert parsed_stats["power_mw"] == 5715
    end
  end
end
