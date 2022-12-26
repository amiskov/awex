#!/bin/sh

set -e

# Install the app's depedencies
mix deps.get

# Wait for Postgres to become available.
while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER 
do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done
echo "\nPostgres is available: continuing with database setup..."

echo "\n Compiling project..."
mix deps.get --only prod
mix compile

# Compile assets
mix assets.deploy
# mix phx.digest

# Custom tasks (like DB migrations)
mix ecto.setup
mix ecto.migrate

echo "\n Launching Phoenix web server..."
mix phx.server

# We can run it in detached mode but since we use Docker Compose, then
# we run docker compose itself in detached mod
# PORT=4001 MIX_ENV=prod elixir --erl "-detached" -S mix phx.server
