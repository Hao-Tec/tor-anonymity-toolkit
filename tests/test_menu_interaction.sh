#!/bin/bash
# tests/test_menu_interaction.sh

# Mock sudo and systemctl
function sudo() { :; }
function systemctl() {
  return 0
}

# Source the script with 'help' to load functions
source ./anonymity.sh help > /dev/null

# Mock disable_all
function disable_all() {
  echo "MOCK_DISABLE_ALL_CALLED"
}

echo "--- Test 1: Decline Confirmation ---"
# Input: 5 -> n -> x -> q
# Note: x is consumed by 'read -n 1' (Press any key)
output=$(printf "5\nn\nxq\n" | interactive_menu)

if echo "$output" | grep -q "MOCK_DISABLE_ALL_CALLED"; then
  echo "FAIL: disable_all WAS called (should be skipped)."
  echo "$output"
else
  echo "PASS: disable_all was NOT called."
fi

if echo "$output" | grep -q "Cancelled"; then
  echo "PASS: 'Cancelled' message found."
else
  echo "FAIL: 'Cancelled' message not found."
fi

echo "--- Test 2: Accept Confirmation ---"
# Input: 5 -> y -> x -> q
output=$(printf "5\ny\nxq\n" | interactive_menu)

if echo "$output" | grep -q "MOCK_DISABLE_ALL_CALLED"; then
  echo "PASS: disable_all WAS called."
else
  echo "FAIL: disable_all was NOT called."
  echo "$output"
fi

echo "--- Test 3: Verify New Label ---"
if echo "$output" | grep -q "Turn \[o\]ff Tor + NEWNYM"; then
  echo "PASS: Found new label 'Turn [o]ff Tor + NEWNYM'."
else
  echo "FAIL: New label not found."
  echo "$output" | grep "5)"
fi
