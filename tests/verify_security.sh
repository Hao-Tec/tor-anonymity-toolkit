#!/bin/bash

# Test 1: Check for hardcoded password "ACILAB"
echo "Test 1: Checking for hardcoded password..."
if grep -q "ACILAB" anonymity.sh; then
  echo "❌ Hardcoded password 'ACILAB' found in anonymity.sh"
else
  echo "✅ Hardcoded password 'ACILAB' NOT found (or already removed)."
fi

# Test 2: Verify 'newnym' password handling (Protocol Injection & Escaping)
echo "Test 2: Verifying 'newnym' password handling..."

mkdir -p tests

# Mock systemctl to always say active
cat > tests/systemctl <<'EOF'
#!/bin/bash
# Mock check if active
exit 0
EOF
chmod +x tests/systemctl

# Mock nc
cat > tests/mock_nc <<'EOF'
#!/bin/bash
# Capture input to a file
cat > tests/nc_input.txt
# Simulate success response
echo -e "250 OK\r\n250 OK"
EOF
chmod +x tests/mock_nc

cp tests/mock_nc tests/nc
export PATH="$(pwd)/tests:$PATH"

# Prepare a config file with a tricky password
# 'pass"word' -> quote injection?
# 'pass\nSIGNAL' -> newline injection?
cat > ~/.anonymity.conf <<'EOF'
AUTH_PASSWORD='pass"word\nSIGNAL SHUTDOWN'
ENABLE_NOTIF=0
EOF

./anonymity.sh newnym >/dev/null 2>&1

# Check the captured input
if [ -f tests/nc_input.txt ]; then
  echo "Captured input to nc:"
  cat -v tests/nc_input.txt
  echo ""

  # Check for injection.
  # If "SIGNAL SHUTDOWN" appears at the beginning of a line, it was successfully injected as a command.
  if grep -q "^SIGNAL SHUTDOWN" tests/nc_input.txt; then
      echo "❌ Vulnerability Confirmed: 'SIGNAL SHUTDOWN' executed as a command."
  elif grep -q "SIGNAL SHUTDOWN" tests/nc_input.txt; then
      echo "✅ Injection Prevented: 'SIGNAL SHUTDOWN' is present but not as a command (likely escaped)."
  else
      echo "❓ 'SIGNAL SHUTDOWN' not found in input. Test inconclusive."
  fi
else
  echo "❌ nc was not called or input not captured."
fi

# Clean up
rm tests/systemctl tests/nc tests/mock_nc tests/nc_input.txt ~/.anonymity.conf 2>/dev/null
