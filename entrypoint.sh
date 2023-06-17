#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /grow-api/tmp/pids/server.pid

# if [ "$RAILS_ENV" = "production" ]; then
#   cp config/database.yml.prod config/database.yml
# else
#   cp config/database.yml.dev config/database.yml
# fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
