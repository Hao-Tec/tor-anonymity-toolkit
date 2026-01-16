#!/bin/bash

# Mock dependencies
function command() {
  return 0
}
export -f command

function notify-send() {
  return 0
}
export -f notify-send

# Mock logs
export LOGFILE="test_log.txt"
touch "$LOGFILE"

# Mock curl to track calls
function curl() {
  # Log the call
  if [[ "$*" == *"--noproxy"* ]]; then
    echo "REAL_IP_FETCH" >> curl_calls.log
    echo "192.168.1.100" # Mock Real IP
  elif [[ "$*" == *"--socks5-hostname"* ]]; then
    echo "TOR_IP_FETCH" >> curl_calls.log
    echo "10.10.10.10"   # Mock Tor IP
  else
    echo "UNKNOWN_CURL" >> curl_calls.log
  fi
}
export -f curl

# Mock sleep to control loop iterations
function sleep() {
  echo "SLEEP" >> sleep_calls.log
  count=$(wc -l < sleep_calls.log)
  if [[ $count -ge 2 ]]; then
    echo "Loop limit reached, exiting..."
    exit 0
  fi
}
export -f sleep

# Clean previous logs
rm -f curl_calls.log sleep_calls.log

# Source the script but don't run main execution
# We can do this by defining a function with the same name as the last command or using 'return'
# But anonymity.sh executes code at the bottom.
# We can start it with a dummy argument that triggers a function, or just extract the function.
# Or, simpler:
# The script has a `case "$1" in` block. If I pass "monitor", it runs monitor_loop.
# I want to run monitor_loop but with my mocks.

# The script `anonymity.sh` checks dependencies at the top unless $1 is help.
# My mock `command` handles check_dependencies.

# Run the monitor command
# We use timeout just in case sleep logic fails
timeout 5s ./anonymity.sh monitor >/dev/null

# Analyze results
echo "Analysis:"
real_ip_calls=$(grep -c "REAL_IP_FETCH" curl_calls.log)
echo "Real IP fetch count: $real_ip_calls"

if [[ $real_ip_calls -gt 1 ]]; then
  echo "FAIL: Real IP was fetched multiple times ($real_ip_calls)"
else
  echo "SUCCESS: Real IP was fetched $real_ip_calls times (<= 1 is good, assuming we ran 2 loops)"
fi

# Check loop iterations
loops=$(grep -c "SLEEP" sleep_calls.log)
echo "Loop iterations: $loops"
