#!/bin/bash

# Setup temp home
TEST_HOME=$(mktemp -d)
export HOME="$TEST_HOME"
trap 'rm -rf "$TEST_HOME"' EXIT

# Start Mock Server
python3 tests/mock_tor_control.py &
MOCK_PID=$!
# Wait for port to be open using bash tcp
timeout 5 bash -c 'until (echo > /dev/tcp/127.0.0.1/9052) 2>/dev/null; do sleep 0.1; done'

# Mock systemctl to bypass "Tor is not running" check
function systemctl() {
    return 0
}
export -f systemctl

# Source script
if [ -f "./anonymity.sh" ]; then
    source ./anonymity.sh help
else
    echo "Error: anonymity.sh not found in current directory"
    kill $MOCK_PID
    exit 1
fi

# Override Control Port for test
CONTROL_PORT=9052
AUTH_PASSWORD="test"

# Mock spinner
spinner() {
    wait "$1"
}
export -f spinner

echo "Running newnym..."
if newnym; then
    echo "TEST PASS: newnym returned success"
else
    echo "TEST FAIL: newnym returned failure"
    kill $MOCK_PID
    exit 1
fi

kill $MOCK_PID
exit 0
