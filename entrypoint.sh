#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /opencell/tmp/pids/server.pid
printenv
# Then exec the container's main process (what's set as CMD in the Dockerfile).
freshclam
echo "Fetched AV DB"
freshclam -d
echo "Started AV Fetch Daemon"
clamd
echo "Started AV service"
bundle exec sidekiq -d -e $ENVIRONMENT n -C config/sidekiq.yml &
echo "Started Sidekiq"
exec "$@"