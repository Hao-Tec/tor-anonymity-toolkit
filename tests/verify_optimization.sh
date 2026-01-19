#!/bin/bash

# Output file for tracking
TRACK_FILE="curl_calls.log"
rm -f "$TRACK_FILE"

# Source the script with 'help' to avoid execution
source ./anonymity.sh help > /dev/null

# Mock curl (overwrite existing command/function)
function curl() {
  echo "curl called with args: $*" >> "$TRACK_FILE"
  if [[ "$*" == *"--noproxy"* ]]; then
      echo "1.2.3.4" # Real IP
  else
      echo "5.6.7.8" # Tor IP
  fi
}
export -f curl

# Mock sleep to break loop after 2 iterations
ITERATIONS=0
function sleep() {
  ITERATIONS=$((ITERATIONS + 1))
  if [[ $ITERATIONS -ge 2 ]]; then
    exit 0 # Exit the subshell
  fi
}
export -f sleep

# Mock UI/Logging functions to reduce noise (overwrite loaded functions)
function append_log() { :; }
function send_notification() { :; }
export -f append_log
export -f send_notification

# Run monitor_loop in a subshell so the exit in sleep doesn't kill this script
( monitor_loop ) > /dev/null

# Analyze results
REAL_IP_CALLS=$(grep -c "noproxy" "$TRACK_FILE")
echo "Real IP fetch calls: $REAL_IP_CALLS"

if [[ $REAL_IP_CALLS -ge 2 ]]; then
  echo "Verified: Real IP is fetched on every iteration (Unoptimized)."
elif [[ $REAL_IP_CALLS -eq 1 ]]; then
  echo "Verified: Real IP is fetched only once (Optimized)."
else
  echo "Unexpected call count: $REAL_IP_CALLS"
fi
