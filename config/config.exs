# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :awex,
  ecto_repos: [Awex.Repo]

# Configures the endpoint
config :awex, AwexWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AwexWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Awex.PubSub,
  live_view: [signing_salt: "spA8bCQZ"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :awex, Awex.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :awex, GITHUB_USER_TOKEN: System.get_env("GITHUB_USER_TOKEN")
config :awex, GITHUB_GRAPHQL_URL: "https://api.github.com/graphql"
config :awex, AWESOME_LIST_URL: "https://github.com/h4cc/awesome-elixir/blob/master/README.md"

# config :awex, Awex.Scheduler,
#   jobs: [
#     update_at_midnight: [
#       schedule: "@daily",
#       task: {Awex.Workers.FetchAndStore, :run, []},
#     ],
#     update_on_start: [
#       schedule: "@reboot",
#       task: {Awex.Workers.FetchAndStore, :run, []},
#     ]
#   ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
