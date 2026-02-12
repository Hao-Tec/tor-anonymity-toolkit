#!/bin/bash
# tests/test_config_setup.sh

# Create a temporary directory for HOME
TEST_HOME=$(mktemp -d)
export HOME="$TEST_HOME"

# Path to the script under test
SCRIPT_PATH="$(realpath ./anonymity.sh)"

# Ensure we clean up
trap 'rm -rf "$TEST_HOME"' EXIT

echo "Running anonymity.sh to generate config (Non-interactive)..."
# Capture output, use help command
OUTPUT=$("$SCRIPT_PATH" help < /dev/null 2>&1)

CONFIG_FILE="$TEST_HOME/.anonymity.conf"

if [[ -f "$CONFIG_FILE" ]]; then
  echo "Config file created."
  if grep -q 'AUTH_PASSWORD="CHANGE_ME"' "$CONFIG_FILE"; then
    echo "SUCCESS: Found 'CHANGE_ME' in config."
  else
    echo "FAIL: Did not find 'CHANGE_ME' in config."
  fi
else
  echo "FAIL: Config file was not created."
fi

# Check for warning in output
if echo "$OUTPUT" | grep -q "Security Warning: AUTH_PASSWORD is set to 'CHANGE_ME'"; then
  echo "SUCCESS: Warning message displayed."
else
  echo "FAIL: Warning message NOT displayed."
  echo "Output was:"
  echo "$OUTPUT"
fi
