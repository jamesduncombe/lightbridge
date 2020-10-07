defmodule Lightbridge.Hs100Test do
  use ExUnit.Case

  alias Lightbridge.Hs100

  describe "get_time/0" do
    test "gets time" do
      Hs100.get_time()
    end
  end

  describe "get_sysinfo/0" do
    test "gets system info" do
      Hs100.get_sysinfo()
    end
  end

  describe "" do
    test "gets live energy usage" do
      Hs100.get_energy()
    end
  end

  describe "turn_on/0" do
    test "turns on the switch" do
      Hs100.turn_on()
    end
  end

  describe "turn_off/0" do
    test "turns off the switch" do
      Hs100.turn_off()
    end
  end

  describe "encrypt/1" do
    test "encrypts the command to send to the switch" do
      command = ~s({"system":{"set_relay_state":{"state":1}}})

      encrypted = Hs100.encrypt(command)

      assert encrypted == [
               0,
               0,
               0,
               42,
               208,
               242,
               129,
               248,
               139,
               255,
               154,
               247,
               213,
               239,
               148,
               182,
               197,
               160,
               212,
               139,
               249,
               156,
               240,
               145,
               232,
               183,
               196,
               176,
               209,
               165,
               192,
               226,
               216,
               163,
               129,
               242,
               134,
               231,
               147,
               246,
               212,
               238,
               223,
               162,
               223,
               162
             ]
    end
  end

  describe "decrypt/1" do
    test "decrypts payloads from the switch" do
      decrypted =
        "0000002ad0f281f88bff9af7d5ef94b6c5a0d48bf99cf091e8b7c4b0d1a5c0e2d8a381f286e793f6d4eedfa2dfa2"
        |> Base.decode16!(case: :lower)
        |> Hs100.decrypt()

      assert decrypted == '{"system":{"set_relay_state":{"state":1}}}'
    end
  end
end