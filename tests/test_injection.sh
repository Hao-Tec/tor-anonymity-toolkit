#!/bin/bash
set -u

# Ensure we are running from repo root or correct location
if [[ ! -f "anonymity.sh" ]]; then
  echo "Error: anonymity.sh not found in current directory."
  exit 1
fi

TEST_DIR="$PWD/tests"
if [[ ! -x "$TEST_DIR/nc" || ! -x "$TEST_DIR/systemctl" ]]; then
  echo "Error: mocks not found in tests/ directory."
  exit 1
fi

export PATH="$TEST_DIR:$PATH"
export NC_CAPTURE_FILE="$TEST_DIR/nc_capture.txt"

# Create a temporary home directory
TEST_HOME=$(mktemp -d)
export HOME="$TEST_HOME"

# Clean up on exit
cleanup() {
  rm -rf "$TEST_HOME"
  rm -f "$NC_CAPTURE_FILE"
}
trap cleanup EXIT

# Create a config with a special password
# Password: bad"pass\word
# Expected Protocol String: "bad\"pass\\word"
cat > "$HOME/.anonymity.conf" <<EOF
AUTH_PASSWORD='bad"pass\word'
ENABLE_NOTIF=0
THEME="dark"
EOF

# Run newnym
echo "Running anonymity.sh newnym..."
# We pipe yes to avoid any unexpected interactive prompts, just in case.
# But newnym shouldn't prompt.
./anonymity.sh newnym >/dev/null 2>&1

# Check captured output
if [[ ! -f "$NC_CAPTURE_FILE" ]]; then
  echo "FAIL: No output captured from nc."
  exit 1
fi

echo "Captured output sent to nc:"
cat "$NC_CAPTURE_FILE"

# Expected: AUTHENTICATE "bad\"pass\\word"
# grep -F treats pattern as fixed string, no regex chars.
if grep -F 'AUTHENTICATE "bad\"pass\\word"' "$NC_CAPTURE_FILE" >/dev/null; then
  echo "PASS: Password correctly escaped."
else
  echo "FAIL: Password NOT correctly escaped."
  echo "Expected: AUTHENTICATE \"bad\\\"pass\\\\word\""
  exit 1
fi
