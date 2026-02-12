#!/bin/bash

# Create a temporary file for capturing output
CAPTURE_FILE=$(mktemp)
trap 'rm -f "$CAPTURE_FILE"' EXIT

# Mocking netcat to capture input
function nc() {
  cat > "$CAPTURE_FILE"
  echo "250 OK"
  echo "250 OK"
}
export -f nc

# Mocking systemctl to always return true
function systemctl() {
  return 0
}
export -f systemctl

# Mock spinner to avoid delay
function spinner() {
  :
}
export -f spinner

# Source the script but don't run main logic
source ./anonymity.sh help

# Test case 1: Password with backslash and quotes
AUTH_PASSWORD='bad"pass\word'
echo "Testing with password: $AUTH_PASSWORD"
newnym

echo "Captured input:"
cat "$CAPTURE_FILE"

# Analysis
expected_escaped='AUTHENTICATE "bad\"pass\\word"'
actual=$(cat "$CAPTURE_FILE" | head -n 1)

if [[ "$actual" != "$expected_escaped"* ]]; then
    echo "VULNERABILITY CONFIRMED: Password was not properly escaped."
    echo "Expected start: $expected_escaped"
    echo "Actual start:   $actual"
    exit 1
else
    echo "Password seems escaped correctly (unexpected if vulnerable)."
    exit 0
fi
