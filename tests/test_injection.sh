#!/bin/bash

# Setup mock environment
export PATH="$PWD/tests/mock_bin:$PATH"
export HOME=$(mktemp -d)
TEMP_CONF="$HOME/.anonymity.conf"

# Cleanup on exit
trap 'rm -rf "$HOME"' EXIT

# Create a config with a malicious password containing quotes and backslashes
# We want to verify if these break the protocol or allow injection.
# We'll try to inject "INJECTED_CMD"
# The target command is: echo -e "AUTHENTICATE \"$AUTH_PASSWORD\"\r\nSIGNAL NEWNYM\r\nQUIT\r"

# Case 1: Simple quote to break out
# AUTH_PASSWORD='break"out'

# Case 2: Newline injection (if echo -e expands variables first, then interprets escape codes?)
# Actually, bash variables are expanded before echo runs.
# If I put "\r\n" in the variable, echo -e will interpret it!

MALICIOUS_PASS='pwned"\r\nINJECTED_CMD\r\n"'

# Write config
cat > "$TEMP_CONF" <<EOF
AUTH_PASSWORD='$MALICIOUS_PASS'
ENABLE_NOTIF=0
THEME="dark"
EOF

# Run anonymity.sh newnym command
# We use 'bash' to run it
# We need to ensure it uses our mock nc
# We also need to source it or run it. It has a 'newnym' command.

# We need to make sure the script picks up our config.
# It uses $HOME/.anonymity.conf so we are good.

echo "Running anonymity.sh with malicious password..."
bash ./anonymity.sh newnym

# Check the log
echo "Checking nc input log..."
cat tests/nc_input.log

# Verify injection
# The vulnerability is confirmed if INJECTED_CMD appears on its own line or not properly encapsulated.
# In the fixed version, it should be part of the AUTHENTICATE line.

if grep -q "^INJECTED_CMD" tests/nc_input.log; then
    echo "❌ VULNERABILITY CONFIRMED: INJECTED_CMD found as a command (start of line)."
    exit 1
elif grep -q "INJECTED_CMD" tests/nc_input.log; then
    # It exists but not at start of line. Check if it's inside quotes.
    # We expect: AUTHENTICATE "pwned\"\\r\\nINJECTED_CMD\\r\\n\""
    if grep -q 'AUTHENTICATE ".*INJECTED_CMD.*"' tests/nc_input.log; then
        echo "✅ SAFE: INJECTED_CMD found inside AUTHENTICATE quotes."
        exit 0
    else
        echo "❓ WARNING: INJECTED_CMD found but context is unclear."
        cat tests/nc_input.log
        exit 1
    fi
else
    echo "✅ NO INJECTION DETECTED (String not found at all, which is also safe but unexpected given our input)."
    exit 0
fi
