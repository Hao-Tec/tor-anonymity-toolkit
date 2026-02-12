#!/bin/bash
export TERM=xterm
export HOME=$(mktemp -d)

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SCRIPT="$REPO_ROOT/anonymity.sh"

echo "Testing Default Config Generation and Security Check..."

# Run script. It should create config and exit with error
output=$("$SCRIPT" help 2>&1)
exit_code=$?

echo "Output:"
echo "$output"
echo "Exit Code: $exit_code"

if [ $exit_code -ne 1 ]; then
  echo "FAIL: Script did not exit with error (expected 1, got $exit_code)"
  rm -rf "$HOME"
  exit 1
fi

if [[ "$output" != *"SECURITY WARNING"* ]]; then
  echo "FAIL: Output does not contain security warning"
  rm -rf "$HOME"
  exit 1
fi

if [ ! -f "$HOME/.anonymity.conf" ]; then
  echo "FAIL: Config file not created"
  rm -rf "$HOME"
  exit 1
fi

# Check content of config
if ! grep -q 'AUTH_PASSWORD="CHANGE_ME"' "$HOME/.anonymity.conf"; then
  echo "FAIL: Config does not contain CHANGE_ME"
  rm -rf "$HOME"
  exit 1
fi

echo "PASS: Default config triggers security warning."

# Now fix the config
echo "Updating config..."
sed -i 's/AUTH_PASSWORD="CHANGE_ME"/AUTH_PASSWORD="MySecret"/' "$HOME/.anonymity.conf"

# Run again
output=$("$SCRIPT" help 2>&1)
exit_code=$?

if [ $exit_code -ne 0 ]; then
  echo "FAIL: Script failed after config fix (exit code $exit_code)"
  echo "$output"
  rm -rf "$HOME"
  exit 1
fi

echo "PASS: Script works with valid config."
rm -rf "$HOME"
