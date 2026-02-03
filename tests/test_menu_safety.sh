#!/bin/bash
export PATH="$PWD/tests/mock_bin:$PATH"

# Function to run the menu interaction
run_interaction() {
  local input="$1"
  # Use -e for echo to interpret \n
  echo -e "$input" | timeout 5s ./anonymity.sh menu 2>&1
}

echo "Testing Scenario 1: Decline Confirmation (Select 5 -> n -> Quit)"
# Input logic:
# 5 + \n   : Select option 5
# n + \n   : Answer 'n' to confirmation
# .        : Key for 'Press any key'
# q + \n   : Select 'q' to quit (echo adds final \n)
OUTPUT=$(run_interaction "5\nn\n.q")

if echo "$OUTPUT" | grep -q "Action cancelled"; then
  echo "PASS: Cancellation message found."
else
  echo "FAIL: Cancellation message NOT found."
  echo "$OUTPUT"
  exit 1
fi

if echo "$OUTPUT" | grep -q "MOCK SYSTEMCTL: disable --now tor.service"; then
  echo "FAIL: Disable called despite cancellation!"
  exit 1
else
  echo "PASS: Disable NOT called on cancellation."
fi

echo "Testing Scenario 2: Accept Confirmation (Select 5 -> y -> Quit)"
# Input logic:
# 5 + \n   : Select option 5
# y + \n   : Answer 'y' to confirmation
# .        : Key for 'Press any key'
# q + \n   : Select 'q' to quit
OUTPUT=$(run_interaction "5\ny\n.q")

if echo "$OUTPUT" | grep -q "MOCK SYSTEMCTL: disable --now tor.service"; then
  echo "PASS: Disable called on confirmation."
else
  echo "FAIL: Disable NOT called on confirmation."
  echo "$OUTPUT"
  exit 1
fi
