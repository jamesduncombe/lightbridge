import Config

config :lightbridge,
  sender_implementation: Lightbridge.Hs100.TcpSender,
  # IP of the HS100
  hs100_ip: {0, 0, 0, 0},
  # MQTT hostname
  mqtt_host: "",
  # Port of the MQTT server
  mqtt_port: 0,
  # Credentials for the MQTT server
  mqtt_username: "",
  mqtt_password: "",
  # Base MQTT topic for the switch
  mqtt_topic: "home/room/switch"
