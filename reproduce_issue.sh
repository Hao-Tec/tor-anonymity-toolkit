#!/bin/bash

function systemctl() { return 0; }
export -f systemctl
function spinner() { return 0; }
export -f spinner
function nc() { cat > captured_input.txt; echo "250 OK"; echo "250 OK"; }
export -f nc

source ./anonymity.sh help >/dev/null 2>&1

# Test 1: Quote and Backslash
AUTH_PASSWORD='bad\pass"word'
CONTROL_PORT=9051

echo "Test 1: Password '$AUTH_PASSWORD'"
newnym >/dev/null 2>&1
cat captured_input.txt

echo "--------------------------------"

# Test 2: Newline (literal \n in string, not actual newline char)
# If user sets AUTH_PASSWORD='foo\nbar', bash stores literal \ and n.
# printf %s prints literal \ and n.
# Tor protocol needs escaping?
# If we escape \, it becomes \\n. Tor reads \\ as \ and n as n. So "foo\nbar".
# If the user MEANT a newline, they should have used actual newline.
# If the user has a password with a literal backslash and n, it should be preserved.

AUTH_PASSWORD='line\nbreak'
echo "Test 2: Password '$AUTH_PASSWORD'"
newnym >/dev/null 2>&1
cat captured_input.txt
