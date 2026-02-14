#!/bin/bash

# Mock nc
function nc() {
    # Read stdin to file
    cat >> captured_input.txt
    # Return success response for Tor
    printf "250 OK\r\n250 OK\r\n"
}
export -f nc

# Mock systemctl to assume tor is active
function systemctl() {
    # If checking is-active
    if [[ "$1" == "is-active" ]]; then
        return 0
    fi
    return 0
}
export -f systemctl

# Mock spinner to be fast
function spinner() {
    return
}
export -f spinner

# Mock monitor_once to avoid network calls
function monitor_once() {
    echo "Mock monitor_once called"
}
export -f monitor_once

# Mock curl just in case
function curl() {
    echo "Mock curl"
}
export -f curl

# Set the password with special chars
export AUTH_PASSWORD='my\password"with\backslashes'

# Run anonymity.sh with 'newnym' command
# usage of bash explicitly to ensure exported functions are picked up?
bash anonymity.sh newnym

# Check captured output
echo "Captured input:"
cat captured_input.txt

EXPECTED='AUTHENTICATE "my\password\"with\backslashes"\r\nSIGNAL NEWNYM\r\nQUIT\r\n'
# Note: captured_input.txt will contain the actual bytes.
# printf in anonymity.sh outputs \r\n as bytes 0D 0A.

# We can use diff or just grep to verify.
# Let's convert captured output to a representation we can check.
# Or just check if it contains the escaped string.

if grep -F 'AUTHENTICATE "my\password\"with\backslashes"' captured_input.txt >/dev/null; then
    echo "VERIFICATION PASSED: Password was correctly escaped."
else
    echo "VERIFICATION FAILED: Password was not correctly escaped."
    exit 1
fi
