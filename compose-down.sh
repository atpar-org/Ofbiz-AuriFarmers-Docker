#!/bin/bash

# Get the profile from the first argument
PROFILE=$1
shift  # Shift so $@ now contains the rest (container names)

# Validate profile input
if [[ "$PROFILE" != "dev" && "$PROFILE" != "staging" && "$PROFILE" != "prod" ]]; then
  echo "❌ Invalid profile! Use one of: dev, staging, prod"
  exit 1
fi

# Set compose file
COMPOSE_FILE="docker-compose.$PROFILE.yml"

# Check if any services are passed
if [ $# -eq 0 ]; then
  echo "🧹 Stopping and removing ALL containers, volumes, and orphans for profile: $PROFILE"
  docker-compose -f docker-compose.base.yml -f $COMPOSE_FILE down -v --remove-orphans
else
  echo "🛑 Stopping containers [${*}] for profile: $PROFILE"
  docker-compose -f docker-compose.base.yml -f $COMPOSE_FILE stop "$@"
fi
