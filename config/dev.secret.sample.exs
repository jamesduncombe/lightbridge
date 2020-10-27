import Config

config :lightbridge,
  sender_implementation: Lightbridge.Transport.Tcp,
  # IP of the HS100
  hs100_ip: {0, 0, 0, 0},
  # ClientID for MQTT
  mqtt_client_id: :iam_client,
  # MQTT hostname
  mqtt_host: "",
  # Port of the MQTT server
  mqtt_port: 0,
  # Credentials for the MQTT server
  mqtt_username: "",
  mqtt_password: "",
  # Base MQTT topic for the switch
  mqtt_topic: "home/room/switch"
  # Energy topic
  mqtt_energy_topic: "home/room/switch/energy"
