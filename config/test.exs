import Config

config :lightbridge,
  sender_implementation: Lightbridge.Hs100.MockSender,
  hs100_ip: {127, 0, 0, 1},
  mqtt_client_id: :mqtt_client,
  mqtt_host: "",
  mqtt_port: 1111,
  mqtt_username: "",
  mqtt_password: "",
  mqtt_topic: "level1/level2/switch",
  mqtt_energy_topic: "level1/level2/switch/energy"
