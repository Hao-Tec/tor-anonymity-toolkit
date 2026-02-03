#!/bin/bash

# Setup environment
# Ensure we are in the repo root
cd "$(dirname "$0")/.."

# Create mock binaries
mkdir -p tests/mock_bin
export PATH="$PWD/tests/mock_bin:$PATH"

# Mock nc (netcat) - always success for port check (-z)
cat > tests/mock_bin/nc <<'EOF'
#!/bin/bash
if [[ "$1" == "-z" ]]; then
  exit 0
fi
exit 0
EOF
chmod +x tests/mock_bin/nc

# Mock systemctl
cat > tests/mock_bin/systemctl <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x tests/mock_bin/systemctl

# Mock curl
# Usage: curl --socks5-hostname ... "$url"
cat > tests/mock_bin/curl <<'EOF'
#!/bin/bash
# Find the URL (last argument usually)
for arg in "$@"; do
  url="$arg"
done

if [[ "$url" == "https://ident.me" ]]; then
  # Simulate failure for the first checker
  echo ""
  exit 1
elif [[ "$url" == "https://ifconfig.me/ip" ]]; then
  # Simulate success for the second checker
  echo "1.2.3.4"
  exit 0
elif [[ "$url" == "https://icanhazip.com" ]]; then
  echo "1.2.3.4"
  exit 0
else
  echo ""
  exit 1
fi
EOF
chmod +x tests/mock_bin/curl

# Mock notify-send
touch tests/mock_bin/notify-send
chmod +x tests/mock_bin/notify-send

# Helper to prevent the sourced script from exiting
# If the sourced script calls exit, we want to catch it or prevent it.
# anonymity.sh calls exit 1 if check_dependencies fails.
# But we mocked them, so it should be fine.

# Source the script with a dummy argument to hit the default case (show_help) and avoid infinite loops
# We redirect output to /dev/null to keep test output clean
source ./anonymity.sh --test-source-only > /dev/null 2>&1

# Verify initial state
# The global array should be defined
if [[ -z "${IP_CHECKERS[*]}" ]]; then
    echo "Error: IP_CHECKERS array not defined."
    exit 1
fi

EXPECTED_INITIAL_0="https://ident.me"
if [[ "${IP_CHECKERS[0]}" != "$EXPECTED_INITIAL_0" ]]; then
  echo "Error: Initial state matches unexpected order."
  echo "Expected: $EXPECTED_INITIAL_0"
  echo "Actual: ${IP_CHECKERS[0]}"
  exit 1
fi

echo "Initial state verified. Running check_tor_status..."

# Run the function (suppress output)
check_tor_status > /dev/null

# Verify the swap
# ident.me (failed) should swap with ifconfig.me/ip (succeeded)
# Original: [0]=ident, [1]=ifconfig
# New: [0]=ifconfig, [1]=ident

EXPECTED_NEW_0="https://ifconfig.me/ip"
EXPECTED_NEW_1="https://ident.me"

if [[ "${IP_CHECKERS[0]}" == "$EXPECTED_NEW_0" && "${IP_CHECKERS[1]}" == "$EXPECTED_NEW_1" ]]; then
  echo "✅ SUCCESS: Optimization worked! $EXPECTED_NEW_0 promoted to index 0."
  rm -rf tests/mock_bin
  exit 0
else
  echo "❌ FAILURE: Optimization did not work as expected."
  echo "Expected index 0: $EXPECTED_NEW_0"
  echo "Actual index 0: ${IP_CHECKERS[0]}"
  echo "Full array: ${IP_CHECKERS[*]}"
  rm -rf tests/mock_bin
  exit 1
fi
