#!/bin/bash

# Setup environment
export PATH="$PWD/tests/mock_bin:$PATH"
export NC_LOG="$PWD/nc_output.log"
TEST_HOME=$(mktemp -d)
export HOME="$TEST_HOME"

# Clean up
trap 'rm -rf "$TEST_HOME" "$NC_LOG"' EXIT

# Create malicious config
# Payload: foo" \r\nSIGNAL INJECTED\r\nAUTHENTICATE "bar
# We use single quotes for the echo to preserve backslashes in the file content.
echo 'AUTH_PASSWORD="foo\" \\r\\nSIGNAL INJECTED\\r\\nAUTHENTICATE \"bar"' > "$HOME/.anonymity.conf"

# Ensure log file exists so we don't have permissions issues (script tries to chmod it)
touch "$HOME/.tor_anonymity.log"

# Run the script
# Use relative path to anonymity.sh assuming test is run from repo root
"$PWD/anonymity.sh" newnym >/dev/null

# Check the output sent to nc
echo "--- Captured NC Input ---"
cat "$NC_LOG"
echo "-----------------------"

# Check for injection
if grep -q "^SIGNAL INJECTED" "$NC_LOG"; then
  echo "❌ FAIL: Command injection detected!"
  exit 1
else
  # Verify that we authenticated safely (check that the payload is present but escaped/one-line)
  # The payload string "SIGNAL INJECTED" should be present but NOT at the start of the line (except if it was wrapped, but here we expect single line AUTHENTICATE)

  # If grep finds "SIGNAL INJECTED" anywhere, it means it was sent.
  # But we want to ensure it's NOT executed.
  # In Tor control protocol, commands must be on new lines.
  # So `grep "^SIGNAL INJECTED"` is the correct check for execution.

  echo "✅ PASS: No command injection detected."

  # Double check that the password was actually sent (sanity check)
  if grep -q "SIGNAL INJECTED" "$NC_LOG"; then
      echo "   (Payload was sent safely as part of password)"
  else
      echo "   (Warning: Payload not found at all? This might mean AUTH_PASSWORD wasn't used?)"
  fi
  exit 0
fi
