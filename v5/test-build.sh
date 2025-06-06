#!/bin/bash
set -euo pipefail

echo "=== Testing Ghostfire Docker Build ==="
echo "Building Docker image locally..."

# Build the image
docker build -t ghostfire:test-build .

echo "=== Build completed successfully ==="
echo "Testing container startup..."

# Test the container
docker run -d --name ghostfire-test -p 2368:2368 \
  -e url=http://localhost:2368 \
  -e NODE_ENV=production \
  -e database__client=sqlite3 \
  -e database__connection__filename=/var/lib/ghost/content/data/ghost.db \
  ghostfire:test-build

echo "Waiting for Ghost to start..."
sleep 10

# Check if Ghost is running
if curl -f http://localhost:2368 > /dev/null 2>&1; then
  echo "✅ Ghost is running successfully!"
else
  echo "❌ Ghost failed to start"
  docker logs ghostfire-test
  exit 1
fi

# Cleanup
echo "Cleaning up test container..."
docker stop ghostfire-test
docker rm ghostfire-test

echo "=== Test completed successfully ==="
echo "You can now push your changes to trigger GitHub Actions"