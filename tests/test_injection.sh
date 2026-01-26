#!/bin/bash

# Test script for Tor Control Protocol injection vulnerability

# Create a temporary directory for artifacts
TEMP_DIR=$(mktemp -d)
CAPTURE_FILE="$TEMP_DIR/captured_input.txt"
MOCK_HOME="$TEMP_DIR/home"
mkdir -p "$MOCK_HOME"

# cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

# Mock nc to capture input
function nc() {
  cat > "$CAPTURE_FILE"
  # Simulate Tor success response
  echo "250 OK"
  echo "250 OK"
}
export -f nc

# Mock systemctl
function systemctl() {
  return 0
}
export -f systemctl

# Prepare environment
export HOME="$MOCK_HOME"
export NO_COLOR=1
touch "$HOME/.anonymity.conf"

# We need to source the script to access the functions.
# Running 'help' avoids executing the main logic immediately.
source ./anonymity.sh help > /dev/null

echo "Running Injection Tests..."

FAIL=0

# --- Test Case 1: Password with Quotes ---
AUTH_PASSWORD='Bad"Password'
echo "Test 1: Password with quotes: '$AUTH_PASSWORD'"

# Run newnym
newnym > /dev/null

# Read captured input
OUTPUT=$(cat "$CAPTURE_FILE")

# Expected: The quote should be escaped \"
# And it should NOT break the command structure.
# With the BUG, it looks like: AUTHENTICATE "Bad"Password"
# With the FIX, it should look like: AUTHENTICATE "Bad\"Password"

if [[ "$OUTPUT" == *"AUTHENTICATE \"Bad\\\"Password\""* ]]; then
  echo "✅ Test 1 Passed: Quotes are escaped."
else
  echo "❌ Test 1 Failed: Quotes are NOT properly escaped."
  echo "Output was:"
  echo "$OUTPUT"
  FAIL=1
fi

# --- Test Case 2: Protocol Injection ---
# Attempt to inject a new line and a command
AUTH_PASSWORD='Pass"\r\nSIGNAL NEWNYM\r\n'
echo "Test 2: Injection attempt: '$AUTH_PASSWORD'"

newnym > /dev/null
OUTPUT=$(cat "$CAPTURE_FILE")

# With the BUG, echo -e interprets \r\n and creates new lines.
# We check if there are extra newlines or commands.
# We expect the password to be sent as a literal string.

# Count lines in output.
# Standard request has 3 lines: AUTHENTICATE, SIGNAL, QUIT.
# If injection works, we might see more, or we see the injected command on a new line.

# We verify that the injected string is contained safely within the AUTHENTICATE quotes.
# Expected safe output (approximate representation):
# AUTHENTICATE "Pass\"\r\nSIGNAL NEWNYM\r\n"
# (Depending on how printf handles the escape, the backslashes should be literal)

if [[ "$OUTPUT" == *"AUTHENTICATE \"Pass\\\"\\\\r\\\\nSIGNAL NEWNYM\\\\r\\\\n\""* ]]; then
   echo "✅ Test 2 Passed: Injection payloads are treated as literals."
else
   # Strict check might be hard if we don't know exactly how printf outputs,
   # but we can definitely check if the raw newline was injected.

   # Check if "SIGNAL NEWNYM" appears TWICE.
   # The original code sends "SIGNAL NEWNYM".
   # The injection adds another "SIGNAL NEWNYM".

   COUNT=$(echo "$OUTPUT" | grep -c "SIGNAL NEWNYM")
   if [[ $COUNT -gt 1 ]]; then
     echo "❌ Test 2 Failed: 'SIGNAL NEWNYM' appears $COUNT times. Injection successful!"
     echo "Output was:"
     echo "$OUTPUT"
     FAIL=1
   else
      # Also check that the structure is preserved (single line for AUTHENTICATE)
      AUTH_LINE=$(echo "$OUTPUT" | grep "AUTHENTICATE")
      # If the line ends with "Pass", it means the newline broke it.
      if [[ "$AUTH_LINE" == *"Pass\""* && "$AUTH_LINE" != *"NEWNYM"* ]]; then
         echo "❌ Test 2 Failed: AUTHENTICATE line was terminated early."
         FAIL=1
      else
         echo "✅ Test 2 Passed: No extra commands injected."
      fi
   fi
fi

if [[ $FAIL -eq 1 ]]; then
  exit 1
else
  exit 0
fi
