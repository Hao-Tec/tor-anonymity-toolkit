#!/bin/bash

# Setup environment
export LOGFILE="/tmp/anonymity_test_fast.log"
export ENABLE_NOTIF=0

# Mock curl to simulate timeout/delay
function curl() {
  sleep 1
  # Return nothing to simulate failure
}
export -f curl

# Mock notification and logging to avoid noise
function send_notification() { :; }
function append_log() { :; }
export -f send_notification
export -f append_log

# Source the script functions
source ./anonymity.sh help >/dev/null

echo "Running monitor_once with CLOSED port (expecting <1s delay)..."
start=$(date +%s)
monitor_once
end=$(date +%s)
duration=$((end - start))

echo "Duration: $duration seconds"

if [[ $duration -lt 1 ]]; then
  echo "✅ Success: Failed fast as expected."
else
  echo "❌ Failure: Did not fail fast (Duration: $duration)."
  exit 1
fi
