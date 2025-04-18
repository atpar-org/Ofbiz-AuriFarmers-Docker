#!/bin/bash

# Get the profile from the first argument
PROFILE=$1
shift # Shift to next arguments (to capture -d or specific services)

# Validate profile input
if [[ "$PROFILE" != "dev" && "$PROFILE" != "staging" && "$PROFILE" != "prod" ]]; then
  echo "❌ Invalid profile! Use one of: dev, staging, prod"
  exit 1
fi

# Compose files
COMPOSE_FILE="docker-compose.$PROFILE.yml"
ENV_FILE=".env.$PROFILE"

# Check if .env file exists
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Environment file $ENV_FILE not found!"
  exit 1
fi

# Export env vars from the file (so they are available to docker-compose)
set -o allexport
source "$ENV_FILE"
set +o allexport

# Start message
echo "🚀 Starting Docker Compose with profile: $PROFILE"
echo "📦 Using env file: $ENV_FILE"
echo "🔧 Additional options: $@"

# Handle special case: remove specific container
if [[ "$1" == "remove" && -n "$2" ]]; then
  SERVICE=$2
  echo "🛑 Stopping and removing service: $SERVICE"
  docker compose -f docker-compose.base.yml -f $COMPOSE_FILE stop $SERVICE
  docker compose -f docker-compose.base.yml -f $COMPOSE_FILE rm -f $SERVICE
  exit 0
fi

# Run docker-compose with any additional args passed
docker compose -f docker-compose.base.yml -f $COMPOSE_FILE "$@"
