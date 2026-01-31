#!/bin/bash

# Setup environment
export PATH="$PWD/tests/mock_bin:$PATH"
export NC_LOG="$PWD/tests/nc.log"
rm -f "$NC_LOG"

# Source the script under test
# We use 'help' to skip execution but load functions
source ./anonymity.sh help >/dev/null

FAILURES=0

# Test Function
run_test() {
  local password="$1"
  local expected="$2"
  local description="$3"

  echo "TEST: $description"

  # Set global var used by newnym
  AUTH_PASSWORD="$password"
  CONTROL_PORT=9051

  # Clear log
  > "$NC_LOG"

  # Run newnym
  newnym >/dev/null 2>&1

  # Check log
  if [[ ! -f "$NC_LOG" ]]; then
    echo "❌ FAIL: No output to nc"
    FAILURES=$((FAILURES+1))
    return 1
  fi

  # Check if the AUTHENTICATE line matches expected
  # We use grep -F to search for fixed string
  if grep -Fq "$expected" "$NC_LOG"; then
    echo "✅ PASS"
  else
    echo "❌ FAIL"
    echo "  Input: '$password'"
    echo "  Expected in output: '$expected'"
    echo "  Actual output:"
    cat "$NC_LOG"
    FAILURES=$((FAILURES+1))
  fi
}

echo "Starting Security Tests..."

# Test 1: Normal password
run_test "securepassword" 'AUTHENTICATE "securepassword"' "Normal password"

# Test 2: Password with double quotes
# Current vulnerable code produces: AUTHENTICATE "pass"word"
# Desired secure code produces: AUTHENTICATE "pass\"word"
run_test 'pass"word' 'AUTHENTICATE "pass\"word"' "Password with double quotes"

# Test 3: Password with backslashes
# Current vulnerable code produces: AUTHENTICATE "pass\word"
# Desired secure code produces: AUTHENTICATE "pass\\word"
run_test 'pass\word' 'AUTHENTICATE "pass\\word"' "Password with backslashes"


if [[ $FAILURES -eq 0 ]]; then
  echo "All tests passed!"
  exit 0
else
  echo "$FAILURES tests failed."
  exit 1
fi
