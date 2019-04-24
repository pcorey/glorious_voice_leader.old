# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :glorious_voice_leader,
  namespace: GVL

# Configures the endpoint
config :glorious_voice_leader, GVLWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gfYtgK7bX9V0xurP4oCSapAITsV774lAGYbtgBXRf/3ZGNFhHUpvDamEObYzE9Pd",
  render_errors: [view: GVLWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GVL.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Support *.leex
config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

config :glorious_voice_leader, GVLWeb.Endpoint,
  live_view: [
    signing_salt: "k/b1aVeiKDDWDPnSW0rwzyVONO/6RHcv"
  ]

config :glorious_voice_leader, ecto_repos: [Chord.Repo]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
