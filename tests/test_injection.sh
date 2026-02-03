#!/bin/bash
export PATH="$PWD/tests/mock_bin:$PATH"
export TERM=dumb # Avoid tput issues

# Clean previous log
rm -f nc.log

# Source the script with 'help' to load functions but not run main loop
# We need to use a subshell or trickery because sourcing might print help and not return if it had an exit (it doesn't)
source ./anonymity.sh help >/dev/null

# Override variables for test
AUTH_PASSWORD='bad"pass\word'
CONTROL_PORT=9051

# Run newnym
echo "Running newnym with password: $AUTH_PASSWORD"
newnym

# Check log
echo "Checking nc.log..."
cat nc.log

# Assertions
if grep -F 'AUTHENTICATE "bad"pass\word"' nc.log; then
  echo "VULNERABILITY CONFIRMED: Password was not escaped."
  # We want to fail the test if we are confirming vulnerability?
  # Usually tests should pass if code is correct.
  # So this test script is currently designed to FAIL if the code is buggy (vulnerable).
  # Wait, grep returns 0 if found.
  # If found, it means we sent the unescaped password.
  exit 1
else
  # If we implemented the fix, we expect it to be escaped: "bad\"pass\\word"
  if grep -F 'AUTHENTICATE "bad\"pass\\word"' nc.log; then
    echo "SUCCESS: Password was escaped."
    exit 0
  else
    echo "UNKNOWN STATE: check log above."
    exit 2
  fi
fi
