#!/bin/bash
# Safer test script without exit
export TOR_SOCKS="127.0.0.1:9050"
export CYAN=""
export RESET=""
export RED=""
export YELLOW=""
export GREEN=""

# Use temporary file for extracted function
TEMP_FUNC=$(mktemp)

# Extract check_tor_status function to avoid sourcing entire script which might have side effects
sed -n '/function check_tor_status() {/,/^}/p' anonymity.sh > "$TEMP_FUNC"
# Also need debug_log function
sed -n '/function debug_log() {/,/^}/p' anonymity.sh >> "$TEMP_FUNC"
# And constants/variables used
echo 'TOR_SOCKS="127.0.0.1:9050"' >> "$TEMP_FUNC"
echo 'DEBUG_MODE=0' >> "$TEMP_FUNC"
echo 'LOGFILE="/tmp/test.log"' >> "$TEMP_FUNC"

# Mock append_log since it's called
echo 'function append_log() { :; }' >> "$TEMP_FUNC"

source "$TEMP_FUNC"

echo "Test 1: Port closed (Tor not running)"
# We expect "Tor SOCKS proxy NOT reachable" in output
output=$(check_tor_status)
if echo "$output" | grep -q "Tor SOCKS proxy NOT reachable"; then
    echo "PASS: Correctly detected closed port."
else
    echo "FAIL: Did not detect closed port."
    echo "Output: $output"
fi

# Test 2: Port open (Simulated)
echo "Test 2: Port open (Simulated)"
if command -v nc >/dev/null; then
    # Start listener on 9050
    nc -l -p 9050 >/dev/null 2>&1 &
    PID=$!
    sleep 0.5

    # Mock curl
    function curl() { echo ""; }
    export -f curl

    output=$(check_tor_status)
    kill $PID 2>/dev/null

    if echo "$output" | grep -q "Tor SOCKS proxy is reachable"; then
        echo "PASS: Correctly detected open port."
    else
        echo "FAIL: Did not detect open port."
        echo "Output: $output"
    fi
else
    echo "SKIP: nc not found for mocking server."
fi

# Cleanup
rm "$TEMP_FUNC"
