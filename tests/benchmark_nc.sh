#!/bin/bash

# Ensure nc is installed for comparison (mocking it if not, but here we want real benchmark if possible,
# assuming nc is installed per requirements. If not, we skip the nc part).

HOST="127.0.0.1"
PORT="9050"

# Start a dummy listener on 9050 in background if nothing is listening, so we can test success case.
# Or better, pick an unused port for failure case.

# Let's test FAILURE case (port closed) as it involves timeout handling which is the main difference.
# Actually, for localhost, failure is usually immediate "Connection refused".

# Check if port 9050 is open (Tor). If not, we can't test success easily without starting a listener.
# Let's check a random port likely closed, e.g. 9999.
CLOSED_PORT=9999

echo "Benchmarking 100 iterations of port check on CLOSED port localhost:$CLOSED_PORT..."

start_time=$(date +%s%N)
for i in {1..100}; do
    nc -z -w1 127.0.0.1 $CLOSED_PORT 2>/dev/null
done
end_time=$(date +%s%N)
duration_nc=$((end_time - start_time))

echo "nc duration: $((duration_nc/1000000)) ms"

start_time=$(date +%s%N)
for i in {1..100}; do
    (: > /dev/tcp/127.0.0.1/$CLOSED_PORT) 2>/dev/null
done
end_time=$(date +%s%N)
duration_bash=$((end_time - start_time))

echo "bash /dev/tcp duration: $((duration_bash/1000000)) ms"

if (( duration_bash < duration_nc )); then
    echo "Result: Bash /dev/tcp is faster."
else
    echo "Result: nc is faster (unexpected)."
fi
