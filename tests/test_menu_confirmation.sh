#!/bin/bash

# Setup environment
export TERM=xterm

# Create mock bin for nc just in case
mkdir -p mock_bin
touch mock_bin/nc
chmod +x mock_bin/nc
export PATH=$PWD/mock_bin:$PATH

# Source the script (bypass dependency check with 'help')
# We silence the initial help output
source ./anonymity.sh help >/dev/null

# Mock disable_all to verify it's called
function disable_all() {
  echo "MOCK_DISABLE_CALLED"
}

# Mock systemctl to avoid errors during menu status checks
function systemctl() {
  return 0
}
# Export mocks if they were needed in subshells, but interactive_menu runs in main shell here
export -f systemctl

echo "--- Test Case 1: Select 5, say 'n' (No) ---"
# Input sequence:
# 5 (select option)
# n (confirm no - IF PROMPTED. If not prompted, this 'n' might be consumed by 'press any key')
# (any key to continue)
# q (quit)
output_no=$(printf "5\nn\n\nq\n" | interactive_menu)

if echo "$output_no" | grep -q "MOCK_DISABLE_CALLED"; then
  echo "FAIL: disable_all was called (expected NO call for 'n', or currently no prompt exists)"
else
  echo "PASS: disable_all was NOT called"
fi

echo "--- Test Case 2: Select 5, say 'y' (Yes) ---"
output_yes=$(printf "5\ny\n\nq\n" | interactive_menu)

if echo "$output_yes" | grep -q "MOCK_DISABLE_CALLED"; then
  echo "PASS: disable_all was called"
else
  echo "FAIL: disable_all was NOT called"
fi

echo "--- Test Case 3: Verify Menu Text ---"
if echo "$output_no" | grep -F "Turn [o]ff Tor + NEWNYM"; then
  echo "PASS: Menu text updated correctly"
else
  echo "FAIL: Menu text not updated."
fi
