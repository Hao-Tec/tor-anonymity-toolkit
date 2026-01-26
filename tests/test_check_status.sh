#!/bin/bash
export LOGFILE="/tmp/anonymity_test_status.log"
export ENABLE_NOTIF=0

source ./anonymity.sh help >/dev/null

# Mock curl to avoid network
function curl() { echo "1.2.3.4"; }
export -f curl
function append_log() { :; }
export -f append_log
function send_notification() { :; }
export -f send_notification

# Start listener
echo "Starting dummy listener on port 9050..."
python3 -m http.server 9050 &>/dev/null &
PID=$!
sleep 2

echo "Running check_tor_status..."
output=$(check_tor_status)
kill $PID

echo "$output"

if [[ "$output" == *"reachable at 127.0.0.1:9050"* ]]; then
  echo "✅ check_tor_status correctly detected open port."
else
  echo "❌ check_tor_status failed to detect open port."
  exit 1
fi
