#!/bin/bash

export LOGFILE="/tmp/anonymity_test_func.log"
export ENABLE_NOTIF=0

# Mock curl to simulate timeout/delay
function curl() {
  sleep 1
  # Return nothing to simulate failure (so it loops)
}
export -f curl

function send_notification() { :; }
function append_log() { :; }
export -f send_notification
export -f append_log

source ./anonymity.sh help >/dev/null

echo "Starting dummy listener on port 9050..."
python3 -m http.server 9050 &>/dev/null &
PID=$!
sleep 2 # wait for python to bind

echo "Running monitor_once with OPEN port (expecting ~3s delay)..."
start=$(date +%s)
monitor_once
end=$(date +%s)
duration=$((end - start))
kill $PID

echo "Duration: $duration seconds"

if [[ $duration -ge 3 ]]; then
  echo "✅ Success: Logic correctly detects open port and attempts connection."
else
  echo "❌ Failure: Logic skipped connection attempt despite open port (Duration: $duration)."
  exit 1
fi
