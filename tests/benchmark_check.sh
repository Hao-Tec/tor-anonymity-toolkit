#!/bin/bash

PORT=9055
LOG_FILE="server.log"

function start_server() {
  python3 -m http.server $PORT > "$LOG_FILE" 2>&1 &
  SERVER_PID=$!
  sleep 2 # Wait for server to start
  if ! kill -0 $SERVER_PID 2>/dev/null; then
    echo "Server failed to start. Log:"
    cat "$LOG_FILE"
    exit 1
  fi
}

function stop_server() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" 2>/dev/null
    wait "$SERVER_PID" 2>/dev/null
  fi
  rm -f "$LOG_FILE"
}

trap stop_server EXIT

echo "=== Benchmarking Port Check ==="
echo "Target Port: $PORT"

HAS_NC=0
if command -v nc >/dev/null; then
  HAS_NC=1
else
  echo "WARNING: nc not found. Skipping nc benchmark."
fi

# Test 1: Port Closed
echo "Testing with port $PORT CLOSED..."
if [[ $HAS_NC -eq 1 ]]; then
  echo -n "nc: "
  start=$(date +%s%N)
  nc -z -w1 127.0.0.1 $PORT 2>/dev/null
  res_nc=$?
  end=$(date +%s%N)
  echo "Result: $res_nc, Time: $((end-start)) ns"
  if [[ $res_nc -eq 0 ]]; then echo "ERROR: nc returned 0 for closed port"; exit 1; fi
fi

echo -n "bash: "
start=$(date +%s%N)
( > /dev/tcp/127.0.0.1/$PORT ) 2>/dev/null
res_bash=$?
end=$(date +%s%N)
echo "Result: $res_bash, Time: $((end-start)) ns"

if [[ $res_bash -eq 0 ]]; then echo "ERROR: bash returned 0 for closed port"; exit 1; fi

# Test 2: Port Open
start_server
echo "Testing with port $PORT OPEN..."

if [[ $HAS_NC -eq 1 ]]; then
  echo -n "nc: "
  start=$(date +%s%N)
  nc -z -w1 127.0.0.1 $PORT 2>/dev/null
  res_nc=$?
  end=$(date +%s%N)
  echo "Result: $res_nc, Time: $((end-start)) ns"
  if [[ $res_nc -ne 0 ]]; then echo "ERROR: nc returned non-zero for open port"; exit 1; fi
fi

echo -n "bash: "
start=$(date +%s%N)
( > /dev/tcp/127.0.0.1/$PORT ) 2>/dev/null
res_bash=$?
end=$(date +%s%N)
echo "Result: $res_bash, Time: $((end-start)) ns"

if [[ $res_bash -ne 0 ]]; then echo "ERROR: bash returned non-zero for open port"; exit 1; fi

echo "Verification Successful"
