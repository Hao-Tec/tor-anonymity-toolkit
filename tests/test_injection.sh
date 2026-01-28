#!/bin/bash

# Setup temp environment
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
export HOME="$TEST_DIR"
export PATH="$PWD/tests/mock_bin:$PATH"
export NC_OUTPUT_FILE="$TEST_DIR/nc_output.log"

# Create config with malicious password
# The config file is sourced, so we need valid bash syntax.
# We want the variable AUTH_PASSWORD to contain the string: bad"pass
cat > "$HOME/.anonymity.conf" <<EOF
AUTH_PASSWORD='bad"pass'
EOF

echo "Running anonymity.sh newnym with malicious password..."
"$PWD/anonymity.sh" newnym >/dev/null 2>&1

echo "Captured NC input:"
cat "$NC_OUTPUT_FILE"

# Check for vulnerability (unescaped quote)
# Expected vulnerable output: AUTHENTICATE "bad"pass"
if grep -Fq 'AUTHENTICATE "bad"pass"' "$NC_OUTPUT_FILE"; then
  echo "FAIL: Password was not escaped (Vulnerability present)."
  exit 1
fi

# Check for fix (escaped quote)
# Expected fixed output: AUTHENTICATE "bad\"pass"
if grep -Fq 'AUTHENTICATE "bad\"pass"' "$NC_OUTPUT_FILE"; then
    echo "SUCCESS: Password was escaped correctly."
    exit 0
fi

echo "FAIL: Unexpected output."
exit 1
