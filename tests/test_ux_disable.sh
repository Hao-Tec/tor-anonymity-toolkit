#!/bin/bash
set -u

# Setup environment
TEST_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(dirname "$TEST_DIR")"
TEMP_DIR=$(mktemp -d)
MOCKS_DIR="$TEMP_DIR/mocks"
mkdir -p "$MOCKS_DIR"

# Create Mocks
cat > "$MOCKS_DIR/sudo" << 'EOF'
#!/bin/bash
exec "$@"
EOF
cat > "$MOCKS_DIR/systemctl" << 'EOF'
#!/bin/bash
echo "systemctl $@"
EOF
cat > "$MOCKS_DIR/curl" << 'EOF'
#!/bin/bash
echo "curl mock"
EOF
cat > "$MOCKS_DIR/nc" << 'EOF'
#!/bin/bash
echo "250 OK"
EOF
cat > "$MOCKS_DIR/tput" << 'EOF'
#!/bin/bash
:
EOF
chmod +x "$MOCKS_DIR"/*

export PATH="$MOCKS_DIR:$PATH"
export TERM=xterm

# Temporary Home
export HOME="$TEMP_DIR"

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Create a dummy config
echo "AUTH_PASSWORD=test" > "$TEMP_DIR/.anonymity.conf"

echo "Running test from $PROJECT_ROOT"

run_menu() {
    local input="$1"
    # Pipe input into anonymity.sh menu
    # printf generates the keystrokes
    printf "$input" | "$PROJECT_ROOT/anonymity.sh" menu
}

FAIL=0

echo "--- Test 1: Testing Disable Cancel (Option 5 -> n) ---"
# Input: 5 (choose), n (confirm no), \n (press any key), q (quit)
OUTPUT_CANCEL=$(run_menu "5\nn\n\nq\n")

if echo "$OUTPUT_CANCEL" | grep -q "Action cancelled"; then
    echo "PASS: Action cancelled message found."
else
    echo "FAIL: Action cancelled message NOT found."
    FAIL=1
fi

if echo "$OUTPUT_CANCEL" | grep -q "Both services disabled"; then
    echo "FAIL: Disable function WAS called despite cancellation."
    FAIL=1
else
    echo "PASS: Disable function was NOT called."
fi


echo "--- Test 2: Testing Disable Confirm (Option 5 -> y) ---"
# Input: 5 (choose), y (confirm yes), \n (press any key), q (quit)
OUTPUT_CONFIRM=$(run_menu "5\ny\n\nq\n")

if echo "$OUTPUT_CONFIRM" | grep -q "Both services disabled"; then
    echo "PASS: Disable function was called after confirmation."
else
    echo "FAIL: Disable function was NOT called after confirmation."
    echo "$OUTPUT_CONFIRM"
    FAIL=1
fi

exit $FAIL
