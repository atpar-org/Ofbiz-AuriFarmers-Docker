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

# Start message
echo "🚀 Starting Docker Compose with profile: $PROFILE"
echo "🔧 Additional options: $@"

# Run docker-compose with any additional args passed
docker-compose -f docker-compose.base.yml -f $COMPOSE_FILE up "$@"
