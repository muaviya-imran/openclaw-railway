#!/bin/bash
set -e

# Railway compatibility: Skip Docker operations since Docker-in-Docker is not available
if [ -n "$RAILWAY_ENVIRONMENT" ] || [ -n "$RAILWAY_PROJECT_ID" ] || [ ! -S /var/run/docker.sock ]; then
    echo "🚂 Railway environment detected - skipping Docker sandbox setup"
    echo "✅ Using host environment as sandbox (Railway-compatible mode)"
    exit 0
fi

# Inherit DOCKER_HOST if set, or default to socket proxy
export DOCKER_HOST="${DOCKER_HOST:-tcp://docker-proxy:2375}"

echo "🦞 Building OpenClaw Sandbox Base Image..."

# Use python slim as a solid base
BASE_IMAGE="python:3.11-slim-bookworm"
TARGET_IMAGE="openclaw-sandbox:bookworm-slim"

# Check if image already exists
if docker image inspect "$TARGET_IMAGE" >/dev/null 2>&1; then
    echo "✅ Sandbox base image already exists: $TARGET_IMAGE"
    exit 0
fi

echo "   Pulling $BASE_IMAGE..."
docker pull "$BASE_IMAGE"

echo "   Tagging as $TARGET_IMAGE..."
docker tag "$BASE_IMAGE" "$TARGET_IMAGE"

echo "✅ Sandbox base image ready: $TARGET_IMAGE"
