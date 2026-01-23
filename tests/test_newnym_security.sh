#!/bin/bash

# Setup isolation
export HOME=$(mktemp -d)
trap 'rm -rf "$HOME"' EXIT

mkdir -p "$HOME"

# Define paths
REPO_ROOT=$(pwd)
MOCK_BIN="$REPO_ROOT/tests/mock_bin"
export PATH="$MOCK_BIN:$PATH"
export CAPTURE_FILE="$HOME/nc_capture.log"

# Create a config with a tricky password
# Payload: password" with \ backslash
# This tests if the script correctly escapes " and \
cat > "$HOME/.anonymity.conf" <<'EOF'
AUTH_PASSWORD='password" with \ backslash'
ENABLE_NOTIF=0
THEME="dark"
EOF

# Mock systemctl to ensure the script thinks Tor is running
cat > "$MOCK_BIN/systemctl" <<'END'
#!/bin/bash
# Always say active
exit 0
END
chmod +x "$MOCK_BIN/systemctl"

# Run newnym
# We ignore stdout/stderr of the script itself, we care about what reached nc
"$REPO_ROOT/anonymity.sh" newnym >/dev/null 2>&1

# Check result
# The password 'password" with \ backslash' should become 'password\" with \\ backslash'
# The command sent to nc should be: AUTHENTICATE "password\" with \\ backslash"
EXPECTED='AUTHENTICATE "password\" with \\ backslash"'

if [ -f "$CAPTURE_FILE" ]; then
    if grep -Fq "$EXPECTED" "$CAPTURE_FILE"; then
        echo "PASS: Output matches expected escaped string."
        exit 0
    else
        echo "FAIL: Output does not match."
        echo "Expected to find string: $EXPECTED"
        echo "Captured content:"
        cat "$CAPTURE_FILE"
        exit 1
    fi
else
    echo "FAIL: No capture file found. newnym might not have run correctly."
    exit 1
fi
