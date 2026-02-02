#!/bin/bash
export TERM=xterm
export HOME=$(mktemp -d)
MOCK_BIN="$HOME/mock_bin"
mkdir -p "$MOCK_BIN"
export PATH="$MOCK_BIN:$PATH"

# Mock systemctl
cat > "$MOCK_BIN/systemctl" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$MOCK_BIN/systemctl"

# Mock nc
cat > "$MOCK_BIN/nc" <<EOF
#!/bin/bash
# Log stdin to a file in HOME
cat > "$HOME/nc_input.log"
echo "250 OK"
echo "250 OK"
EOF
chmod +x "$MOCK_BIN/nc"

# Create config in temp HOME with payload
cat > "$HOME/.anonymity.conf" <<EOF
AUTH_PASSWORD='safe"password
SIGNAL PWNED'
EOF

# Run anonymity.sh (assuming it's in the parent directory of tests/)
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

"$REPO_ROOT/anonymity.sh" newnym >/dev/null 2>&1

# Check log
if [ -f "$HOME/nc_input.log" ]; then
    CONTENT=$(cat "$HOME/nc_input.log")
    echo "Captured input:"
    echo "$CONTENT"

    # Check for newlines in the password argument (bad) or if the whole thing is one line (good)
    # The fix removes newlines, so we expect "safe\"passwordSIGNAL PWNED"

    if [[ "$CONTENT" == *"SIGNAL PWNED"* ]]; then
        if [[ "$CONTENT" == *"SIGNAL PWNED\""* ]]; then
             echo "PASS: Injection neutralized (part of password string)."
             rm -rf "$HOME"
             exit 0
        elif [[ "$CONTENT" == *"SIGNAL PWNED"* && "$CONTENT" != *$'\nSIGNAL PWNED'* ]]; then
             # It might be in the middle of the string
             echo "PASS: Injection neutralized."
             rm -rf "$HOME"
             exit 0
        else
             echo "FAIL: Injection successful (found 'SIGNAL PWNED' likely as command)."
             rm -rf "$HOME"
             exit 1
        fi
    else
        echo "FAIL: Payload not found in output."
        rm -rf "$HOME"
        exit 1
    fi
else
    echo "FAIL: Log file not found (nc didn't run?)"
    rm -rf "$HOME"
    exit 1
fi
