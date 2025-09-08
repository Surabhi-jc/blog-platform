#!/bin/sh
set -e

# Keep checking until Postgres says "I’m ready"
until pg_isready -h db -p 5432 -U postgres; do
  echo "Postgres is starting up... waiting"
  sleep 2
done

echo "Postgres is ready. Starting Rails..."
exec "$@"
