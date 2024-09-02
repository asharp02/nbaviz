#!/bin/bash

RETRY_COUNT=0
# Exit immediately if a command exits with a non-zero status
set -e

# Wait for the database to be ready
echo "Waiting for database..."
while ! nc -z db 5432; do
  sleep 1
  # Check if the retry count has exceeded the maximum limit
  if [ "$RETRY_COUNT" -ge 10 ]; then
    echo "Reached maximum retry limit. Exiting."
    exit 1
  fi
  ((RETRY_COUNT++))
done

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate

# Collect static files (if needed)
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Start the Django server
echo "Starting server with command: $@"
exec "$@"
