#!/bin/bash
# tests/test_check_status.sh

export HOME=$(mktemp -d)
trap "rm -rf $HOME" EXIT

# Mock dependencies
mkdir -p "$HOME/bin"
# Mock nc (just needs to exist for check_dependencies)
touch "$HOME/bin/nc" && chmod +x "$HOME/bin/nc"
# Mock curl (can just fail or return nothing)
touch "$HOME/bin/curl" && chmod +x "$HOME/bin/curl"
# Mock systemctl (needed for check_dependencies and status checks)
touch "$HOME/bin/systemctl" && chmod +x "$HOME/bin/systemctl"

export PATH="$HOME/bin:$PATH"

# Source the script
# Use 'help' to bypass interactive menu
# We redirect stdout/stderr to avoid noise during sourcing
if ! source ./anonymity.sh help >/dev/null 2>&1; then
    echo "Failed to source anonymity.sh"
    exit 1
fi

echo "Starting tests..."

# Test 1: Port 9050 closed (no listener)
# Ensure nothing is running on 9050 (sanity check)
# kill $(lsof -t -i :9050) 2>/dev/null || true
# In the sandbox, lsof might not be available or permissions might deny.
# We just assume port 9050 is free as we control the env.

output=$(check_tor_status)
if [[ "$output" == *"Tor SOCKS proxy is reachable"* ]]; then
  echo "FAIL: Port closed but reported reachable"
  echo "$output"
  exit 1
fi
if [[ "$output" != *"Tor SOCKS proxy NOT reachable"* ]]; then
  echo "FAIL: Port closed but unexpected output"
  echo "$output"
  exit 1
fi
echo "PASS: Port closed check"

# Test 2: Port 9050 open (listener active)
# Start python listener
python3 -m http.server 9050 >/dev/null 2>&1 &
PID=$!
sleep 3

# Double check if python actually started and bound port?
# ( >/dev/tcp/127.0.0.1/9050 ) 2>/dev/null || echo "Python server failed to bind"

output=$(check_tor_status)
kill $PID

if [[ "$output" != *"Tor SOCKS proxy is reachable"* ]]; then
  echo "FAIL: Port open but reported NOT reachable"
  echo "$output"
  exit 1
fi
echo "PASS: Port open check"

exit 0
