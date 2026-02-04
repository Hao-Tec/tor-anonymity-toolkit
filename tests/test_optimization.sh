#!/bin/bash

# Mock dependencies
function curl() {
  # The last argument is the URL
  local url="${@: -1}"
  # Simulate timeout/failure for the first default URL
  if [[ "$url" == "https://ident.me" ]]; then
     echo ""
     return 1
  elif [[ "$url" == "https://ifconfig.me/ip" ]]; then
     # Success for the second one
     echo "1.2.3.4"
     return 0
  else
     echo ""
     return 1
  fi
}

function nc() {
  return 0
}

function systemctl() {
  return 0
}

function send_notification() {
  :
}

function append_log() {
  :
}

# Pre-define empty config to avoid creating one
export CONFIG_FILE="/dev/null"

# Source the script
# We use 'help' to avoid running interactive menu or checks
# We need to source it from the parent directory context or adjust paths
source ./anonymity.sh help >/dev/null 2>&1

echo "Running monitor_once..."
monitor_once >/dev/null 2>&1

# Check if IP_CHECKERS is defined
if [[ -z "${IP_CHECKERS+x}" ]]; then
  echo "FAIL: IP_CHECKERS is not defined globally."
  exit 1
fi

# Check order
# We expect https://ifconfig.me/ip to be moved to index 0 because it succeeded
if [[ "${IP_CHECKERS[0]}" == "https://ifconfig.me/ip" ]]; then
  echo "PASS: Priority swapped."
else
  echo "FAIL: Priority not swapped. Index 0 is ${IP_CHECKERS[0]}"
  exit 1
fi
