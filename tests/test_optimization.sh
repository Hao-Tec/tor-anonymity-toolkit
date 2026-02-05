#!/bin/bash
# tests/test_optimization.sh

# Mock variables required by anonymity.sh
LOGFILE="/tmp/test_anonymity.log"
TOR_SOCKS="127.0.0.1:9050"
DEBUG_MODE=0
THEME="dark"
RED=''
GREEN=''
CYAN=''
YELLOW=''
RESET=''
ENABLE_NOTIF=0

# Mock tput to avoid errors
function tput() { :; }

# Mock nc
function nc() { return 0; }

# Mock debug_log
function debug_log() { :; }

# Mock curl
function curl() {
  local url="${@: -1}"
  # Simulate ident.me failing (timeout or empty)
  if [[ "$url" == "https://ident.me" ]]; then
     echo ""
  # Simulate ifconfig.me succeeding
  elif [[ "$url" == "https://ifconfig.me/ip" ]]; then
     echo "1.2.3.4"
  # Simulate icanhazip.com succeeding
  elif [[ "$url" == "https://icanhazip.com" ]]; then
     echo "5.6.7.8"
  else
     echo ""
  fi
}

# Source the script with 'help' to load functions but skip execution
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
source "$REPO_ROOT/anonymity.sh" help >/dev/null

# Override IP_CHECKERS for testing (ensure global scope)
IP_CHECKERS=(
  "https://ident.me"
  "https://ifconfig.me/ip"
  "https://icanhazip.com"
)

echo "Initial Order: ${IP_CHECKERS[*]}"

# Call get_tor_ip (silent mode)
# This function is expected to be added to anonymity.sh
if ! command -v get_tor_ip &>/dev/null; then
  echo "Error: get_tor_ip function not found. Optimization not applied yet?"
  exit 1
fi

get_tor_ip 0
result="$FOUND_IP"

echo "Result IP: $result"

if [[ "$result" != "1.2.3.4" ]]; then
  echo "FAIL: Did not get correct IP. Got '$result'"
  exit 1
fi

echo "New Order: ${IP_CHECKERS[*]}"

# Verify order: ident.me failed, ifconfig.me succeeded.
# New order should have ifconfig.me at index 0.
if [[ "${IP_CHECKERS[0]}" != "https://ifconfig.me/ip" ]]; then
  echo "FAIL: Checker was not promoted. First element is ${IP_CHECKERS[0]}"
  echo "Expected: https://ifconfig.me/ip"
  exit 1
fi

# Verify the old first element is pushed back
if [[ "${IP_CHECKERS[1]}" != "https://ident.me" ]]; then
  echo "FAIL: Old first element not at index 1?"
fi

echo "PASS: Optimization logic verified."
