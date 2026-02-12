#!/bin/bash

# Mock nc to capture input
function nc() {
  cat > nc_input.log
  echo "250 OK"
  echo "250 OK" # Simulate successful authentication and signal
}

export -f nc

# Mock systemctl to always say active
function systemctl() {
  return 0
}
export -f systemctl

# Source the script
source ./anonymity.sh help > /dev/null

# Override the spinner function to be silent and fast
function spinner() {
  :
}

# Override AUTH_PASSWORD with malicious payload
# We use single quotes to pass literals, but we need to ensure the script
# treats them as if they came from a config file (which are read as bash strings)
AUTH_PASSWORD='password"\r\nSIGNAL INJECTED\r\n'

# Run newnym
newnym

# Check the captured input
echo "Captured input:"
cat nc_input.log

# Verify if injection occurred
# We check if "SIGNAL INJECTED" appears at the START of a line.
# The grep anchor '^' matches start of line.
if grep -q "^SIGNAL INJECTED" nc_input.log; then
  echo "FAIL: Injection successful (Command executed)"
  exit 1
else
  # Double check that we didn't just break the whole thing
  # We expect "AUTHENTICATE" to be present
  if grep -q "AUTHENTICATE" nc_input.log; then
      echo "PASS: No injection detected (Payload contained safely)"
  else
      echo "FAIL: Output looks wrong (AUTHENTICATE missing)"
      exit 1
  fi
fi
