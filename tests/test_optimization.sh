#!/bin/bash

# Mock dependencies
function nc() {
  # Mock nc -z success
  return 0
}

function curl() {
  # Mock curl response based on URL
  local url="${@: -1}" # Last argument
  if [[ "$url" == "success_url" ]]; then
    echo "1.2.3.4"
  elif [[ "$url" == "fail_url" ]]; then
    echo "fail"
  else
    # Default behavior for real URLs if they slip through (shouldn't)
    echo ""
  fi
}

function tput() {
  :
}

# Ensure we are testing the script in the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Source the script (suppress output)
# We use 'help' to exit early, but we need the functions.
# Sourcing with 'help' executes the case statement at the end and calls show_help.
# Functions are defined before that.
source "$ROOT_DIR/anonymity.sh" help >/dev/null

# Override global IP_CHECKERS for testing
# This verifies that check_tor_status USES the global variable
IP_CHECKERS=("fail_url" "success_url" "other_url")

echo "Initial IP_CHECKERS: ${IP_CHECKERS[*]}"

# Run check_tor_status
# It should try fail_url, then success_url.
# Then it should swap success_url to the front.
check_tor_status >/dev/null

echo "Final IP_CHECKERS: ${IP_CHECKERS[*]}"

if [[ "${IP_CHECKERS[0]}" == "success_url" ]]; then
  echo "PASS: IP_CHECKERS[0] is 'success_url'"
else
  echo "FAIL: IP_CHECKERS[0] is '${IP_CHECKERS[0]}', expected 'success_url'"
  exit 1
fi
