#!/bin/bash
set -u

# Security Regression Test: Tor Control Protocol Injection
# Ensures that passwords containing newlines or special characters do not inject commands.

# Setup temporary environment
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/bin"
mkdir -p "$TEST_DIR/home"

export PATH="$TEST_DIR/bin:$PATH"
export HOME="$TEST_DIR/home"

# Locate the script under test
SCRIPT_PATH="$(realpath "$PWD/anonymity.sh")"

# Mock systemctl
cat > "$TEST_DIR/bin/systemctl" <<'EOF'
#!/bin/sh
if [ "$1" = "is-active" ]; then
  exit 0
fi
EOF
chmod +x "$TEST_DIR/bin/systemctl"

# Mock nc
cat > "$TEST_DIR/bin/nc" <<'EOF'
#!/bin/sh
# Log stdin to check what was sent
cat > "$HOME/nc_input.log"
echo "250 OK"
echo "250 OK"
EOF
chmod +x "$TEST_DIR/bin/nc"

# Create config with malicious password
# We attempt to inject "INJECTED_COMMAND" by breaking out of the quoted string
MALICIOUS_PW='mypass"\r\nINJECTED_COMMAND\r\n"'

cat > "$HOME/.anonymity.conf" <<EOF
AUTH_PASSWORD='$MALICIOUS_PW'
ENABLE_NOTIF=0
THEME="dark"
EOF

# Run the script
# source the script with "newnym" argument to execute that function?
# No, execute it directly.
"$SCRIPT_PATH" newnym >/dev/null 2>&1

# Verification
# We check if INJECTED_COMMAND appears at the start of a line in the nc input
if grep -q "^INJECTED_COMMAND" "$HOME/nc_input.log"; then
  echo "🚨 VULNERABILITY DETECTED: Protocol injection successful!"
  exit 1
else
  echo "✅ No injection detected (INJECTED_COMMAND not found at start of line)."
  exit 0
fi
