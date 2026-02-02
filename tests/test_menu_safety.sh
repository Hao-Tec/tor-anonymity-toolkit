#!/bin/bash

# Timeout protection
timeout 5s bash -c '
export HOME=$(mktemp -d)

function systemctl() {
  return 0
}
export -f systemctl

function sudo() {
  "$@"
}
export -f sudo

function clear() {
  :
}
export -f clear

source ./anonymity.sh help > /dev/null

function disable_all() {
  echo "MOCK_DISABLED_CALLED"
}
export -f disable_all

echo "--- TESTING DECLINE CONFIRMATION ---"
# Input: 5, n, ., q
# Note: "read -n 1" consumes ".", leaving "q\n" for the next menu choice
printf "5\nn\n.q\n" | interactive_menu 2>&1 | grep -E "Turn \[o\]ff|Are you sure|Operation cancelled|MOCK_DISABLED_CALLED"

echo "--- TESTING ACCEPT CONFIRMATION ---"
# Input: 5, y, ., q
printf "5\ny\n.q\n" | interactive_menu 2>&1 | grep -E "Turn \[o\]ff|Are you sure|Operation cancelled|MOCK_DISABLED_CALLED"
'
