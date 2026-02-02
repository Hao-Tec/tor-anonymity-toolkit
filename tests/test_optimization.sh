#!/bin/bash

# Setup mocks
mkdir -p tests/mock_bin
export PATH="$PWD/tests/mock_bin:$PATH"

# Mock nc to always succeed for port 9050 check
echo -e '#!/bin/bash\nexit 0' > tests/mock_bin/nc
chmod +x tests/mock_bin/nc

# Mock curl to fail first URL, succeed second
cat << 'EOF_CURL' > tests/mock_bin/curl
#!/bin/bash
url="${@: -1}"
# Check based on default order: ident.me is first, ifconfig.me/ip is second
if [[ "$url" == *"ident.me"* ]]; then
  # Simulate failure/timeout
  echo ""
  exit 1
elif [[ "$url" == *"ifconfig.me/ip"* ]]; then
  echo "1.2.3.4"
  exit 0
else
  echo ""
  exit 1
fi
EOF_CURL
chmod +x tests/mock_bin/curl

# Mock systemctl (needed for check_tor_status calls if any)
echo -e '#!/bin/bash\nexit 0' > tests/mock_bin/systemctl
chmod +x tests/mock_bin/systemctl

# Mock notify-send to avoid errors
echo -e '#!/bin/bash\nexit 0' > tests/mock_bin/notify-send
chmod +x tests/mock_bin/notify-send

# Load script
# We use 'help' arg to avoid executing main logic immediately
source ./anonymity.sh help >/dev/null

echo "Initial order: ${IP_CHECKERS[*]}"

# Verify initial order
if [[ "${IP_CHECKERS[0]}" != "https://ident.me" ]]; then
  echo "Error: Initial order is wrong. Found: ${IP_CHECKERS[0]}"
  exit 1
fi

# Run check_tor_status
# This should try ident.me (fail), then ifconfig.me/ip (success), and swap ifconfig.me/ip to front.
# We suppress output to focus on result
check_tor_status >/dev/null 2>&1

echo "Final order: ${IP_CHECKERS[*]}"

# Verify new order
if [[ "${IP_CHECKERS[0]}" == "https://ifconfig.me/ip" ]]; then
  echo "✅ Optimization Verified: Successful URL promoted to front."
else
  echo "❌ Optimization Failed: URL was not promoted."
  echo "Expected: https://ifconfig.me/ip"
  echo "Actual: ${IP_CHECKERS[0]}"
  exit 1
fi

# Reset IP_CHECKERS for monitor_once test
IP_CHECKERS=("https://ident.me" "https://ifconfig.me/ip" "https://icanhazip.com" "https://checkip.amazonaws.com")
echo "Reset order: ${IP_CHECKERS[*]}"

# Run monitor_once
monitor_once >/dev/null 2>&1

echo "Final order after monitor_once: ${IP_CHECKERS[*]}"

if [[ "${IP_CHECKERS[0]}" == "https://ifconfig.me/ip" ]]; then
  echo "✅ monitor_once Optimization Verified"
else
  echo "❌ monitor_once Optimization Failed"
  exit 1
fi

exit 0
