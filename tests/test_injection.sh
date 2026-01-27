#!/bin/bash
set -e

# Ensure we are in the repo root
if [[ ! -f "anonymity.sh" ]]; then
  echo "Error: Must run from repository root"
  exit 1
fi

# Setup environment
export PATH="$PWD/tests/mock_bin:$PATH"
TEMP_HOME=$(mktemp -d)
export HOME="$TEMP_HOME"

# Clean up on exit
trap 'rm -rf "$TEMP_HOME" nc_input.log' EXIT

# Create config with dangerous password containing backslashes and quotes
# This simulates an attempt to inject commands using the Tor Control Protocol
# \r\n are literal characters here, which echo -e would interpret as newlines
cat > "$HOME/.anonymity.conf" <<EOF
AUTH_PASSWORD='pass"word\r\nSIGNAL SHUTDOWN'
ENABLE_NOTIF=0
THEME="dark"
EOF

echo "Running newnym with malicious config..."
# Run anonymity.sh newnym
"$PWD/anonymity.sh" newnym < /dev/null

# Verify the input sent to nc
if [ ! -f nc_input.log ]; then
  echo "Error: nc_input.log not found!"
  exit 1
fi

CONTENT=$(cat nc_input.log)
echo "Captured Content:"
echo "$CONTENT"

# Check for vulnerability
# 1. Double quotes should be escaped: \"
# 2. Backslashes should be preserved/escaped (printf won't expand \r\n to newlines)

if [[ "$CONTENT" != *'pass\"word'* ]]; then
     echo "FAIL: Password double-quote was NOT escaped."
     exit 1
fi

# Check for safety against injection
# We expect the payload to be contained within the quotes of the AUTHENTICATE command
# and NOT executing a new signal.

# The captured content showing vulnerability looks like:
# AUTHENTICATE "pass"word
# SIGNAL SHUTDOWN"
# ...

# The fixed content should look like:
# AUTHENTICATE "pass\"word\r\nSIGNAL SHUTDOWN"
# ...

if [[ "$CONTENT" == *"SIGNAL SHUTDOWN"* ]]; then
     # Check if it's on a new line?
     # We can check if the line starting with SIGNAL SHUTDOWN exists.
     if echo "$CONTENT" | grep -q "^SIGNAL SHUTDOWN"; then
         echo "FAIL: Command Injection Successful! 'SIGNAL SHUTDOWN' found on new line."
         exit 1
     fi
fi

echo "Test passed!"
