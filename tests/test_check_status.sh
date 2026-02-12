#!/bin/bash
# Setup temp home
TEST_HOME=$(mktemp -d)
export HOME="$TEST_HOME"
trap 'rm -rf "$TEST_HOME"' EXIT

# Source script
if [ -f "./anonymity.sh" ]; then
    source ./anonymity.sh help
else
    echo "Error: anonymity.sh not found"
    exit 1
fi

# Start listener on 9050
python3 -c "import socket; s = socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1); s.bind(('127.0.0.1', 9050)); s.listen(1); import time; time.sleep(10)" &
PID=$!
# Wait for port using bash tcp to be sure
timeout 5 bash -c 'until (echo > /dev/tcp/127.0.0.1/9050) 2>/dev/null; do sleep 0.1; done'

# Check status
# We expect "Tor SOCKS proxy is reachable"
# We strip color codes for easier matching
output=$(check_tor_status | sed 's/\x1b\[[0-9;]*m//g')

echo "Output from check_tor_status:"
echo "$output"

if [[ "$output" == *"Tor SOCKS proxy is reachable"* ]]; then
  echo "TEST PASS: Port detected"
else
  echo "TEST FAIL: Port not detected"
  kill $PID
  exit 1
fi

kill $PID
exit 0
