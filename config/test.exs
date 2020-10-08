import Config

config :lightbridge,
  sender_implementation: Lightbridge.Hs100.MockSender

import_config "#{Mix.env()}.secret.exs"
