#!/bin/bash

# Define mocks BEFORE sourcing if possible, but anonymity.sh overwrites them if they are function definitions?
# No, sourcing defines functions. If I define them after, I overwrite them.

# We need to run this in a subshell or separate process to ensure source doesn't pollute.
# We will construct the test execution as a string passed to bash.

export NO_COLOR=1

TEST_SCRIPT=$(cat <<'EOF'
# Source script
source ./anonymity.sh help >/dev/null 2>&1

# Mock disable_all
function disable_all() {
  echo "MOCK_DISABLE_CALLED"
}

# Mock systemctl
function systemctl() {
  return 0
}

# Mock check_tor_status
function check_tor_status() {
  return 0
}

# Run menu
interactive_menu
EOF
)

echo "--- Test 1: Option 5 with 'y' confirmation ---"
# Input: 5, y, press-key, q
INPUT=$(printf "5\ny\n \nq\n")
OUTPUT=$(echo "$TEST_SCRIPT" | timeout 2s bash -c "cat - <(echo \"$INPUT\") | bash 2>&1")

if echo "$OUTPUT" | grep -q "MOCK_DISABLE_CALLED"; then
  echo "PASS (Partial): disable_all called."
else
  echo "FAIL: disable_all NOT called."
fi

# In the future (after fix), we want to verify that 'n' prevents the call.
echo "--- Test 2: Option 5 with 'n' confirmation ---"
INPUT=$(printf "5\nn\n \nq\n")
OUTPUT_NO=$(echo "$TEST_SCRIPT" | timeout 2s bash -c "cat - <(echo \"$INPUT\") | bash 2>&1")

if echo "$OUTPUT_NO" | grep -q "MOCK_DISABLE_CALLED"; then
  echo "FAIL: disable_all called despite 'n'."
else
  echo "PASS: disable_all NOT called with 'n'."
fi
