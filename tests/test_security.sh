#!/bin/bash
# Security Regression Test for Tor Control Port Injection
#
# This test mocks 'nc' and verifies that 'newnym' function
# properly escapes passwords containing quotes and backslashes,
# preventing command injection.

# Setup mock environment
mkdir -p tests/mock_bin
cat > tests/mock_bin/nc <<'EOF'
#!/bin/bash
if [[ -n "$NC_LOG" ]]; then
  cat > "$NC_LOG"
fi
echo "250 OK"
echo "250 OK"
EOF
chmod +x tests/mock_bin/nc

cat > tests/mock_bin/systemctl <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x tests/mock_bin/systemctl

export PATH="$PWD/tests/mock_bin:$PATH"
export NC_LOG="$PWD/tests/nc_output.log"
export TERM=xterm
export HOME=$(mktemp -d)
touch "$HOME/.anonymity.conf"

# Source functionality (ignoring dependencies)
# We use a subshell or source with arguments to avoid running main logic
source ./anonymity.sh help > /dev/null 2>&1

echo "Running Security Tests..."
FAIL=0

# Test 1: Quote Injection
echo "Testing Quote Injection..."
AUTH_PASSWORD='bad"pass'
newnym > /dev/null 2>&1
EXPECTED='AUTHENTICATE "bad\"pass"'
if ! grep -Fq "$EXPECTED" "$NC_LOG"; then
  echo "❌ Test 1 Failed: Quote not escaped properly."
  echo "Expected: $EXPECTED"
  echo "Got:"
  cat "$NC_LOG"
  FAIL=1
else
  echo "✅ Test 1 Passed"
fi

# Test 2: Backslash Injection
echo "Testing Backslash Injection..."
AUTH_PASSWORD='bad\pass'
newnym > /dev/null 2>&1
EXPECTED='AUTHENTICATE "bad\\pass"'
if ! grep -Fq "$EXPECTED" "$NC_LOG"; then
  echo "❌ Test 2 Failed: Backslash not escaped properly."
  echo "Expected: $EXPECTED"
  echo "Got:"
  cat "$NC_LOG"
  FAIL=1
else
  echo "✅ Test 2 Passed"
fi

# Test 3: Newline/Command Injection
echo "Testing Command Injection..."
AUTH_PASSWORD='pass"\r\nSIGNAL SHUTDOWN'
newnym > /dev/null 2>&1
# Check if SIGNAL SHUTDOWN appears at the start of a line (executed command)
# grep ^pattern checks for start of line
if grep -q "^SIGNAL SHUTDOWN" "$NC_LOG"; then
  echo "❌ Test 3 Failed: Command Injection Successful!"
  cat "$NC_LOG"
  FAIL=1
else
  # Verify it is safely inside the AUTHENTICATE command
  if grep -Fq 'AUTHENTICATE "pass\"\\r\\nSIGNAL SHUTDOWN"' "$NC_LOG"; then
      echo "✅ Test 3 Passed: Injection prevented."
  else
      echo "❌ Test 3 Failed: Unexpected output format."
      cat "$NC_LOG"
      FAIL=1
  fi
fi

# Cleanup
rm -rf "$HOME"
rm -rf tests/mock_bin
rm -f "$NC_LOG"
rm -f tests/repro_injection.sh tests/repro_injection_2.sh

if [[ $FAIL -eq 0 ]]; then
    echo "🎉 All security tests passed."
    exit 0
else
    echo "🔥 Security tests failed."
    exit 1
fi
