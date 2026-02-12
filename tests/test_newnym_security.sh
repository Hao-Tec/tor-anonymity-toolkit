#!/bin/bash

# Setup temporary capture file
CAPTURE_FILE=$(mktemp)
export CAPTURE_FILE

# Mock systemctl to pretend service is active
function systemctl() {
  return 0
}
export -f systemctl

# Mock nc to capture input
function nc() {
  # Capture stdin to file
  cat > "$CAPTURE_FILE"
  # Simulate successful response
  echo "250 OK"
  echo "250 OK"
}
export -f nc

# Mock spinner to avoid delay/output issues
function spinner() {
  :
}
export -f spinner

# Source the script with 'help' to load functions but skip execution
# Use absolute path or assume running from root
source "$PWD/anonymity.sh" help > /dev/null 2>&1

# Set a tricky password
export AUTH_PASSWORD='pass\word"quote'
export CONTROL_PORT=9051

# Call newnym
# newnym function waits for the background process
newnym > /dev/null 2>&1

# Read captured file
CAPTURED=$(cat "$CAPTURE_FILE")
echo "Captured Input:"
echo "$CAPTURED"

# Check for expected escaped string
# Expected: AUTHENTICATE "pass\\word\"quote"
EXPECTED_SUBSTRING='AUTHENTICATE "pass\\word\"quote"'

if [[ "$CAPTURED" == *"$EXPECTED_SUBSTRING"* ]]; then
  echo "✅ TEST PASSED: Password was correctly escaped."
  rm "$CAPTURE_FILE"
  exit 0
else
  echo "❌ TEST FAILED: Password was NOT correctly escaped."
  echo "Expected to find: $EXPECTED_SUBSTRING"
  rm "$CAPTURE_FILE"
  exit 1
fi
