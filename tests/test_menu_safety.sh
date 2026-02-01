#!/bin/bash

# Setup mock environment
TEST_DIR="$(dirname "$0")"
MOCK_BIN="$TEST_DIR/mock_bin"
mkdir -p "$MOCK_BIN"

# Create mock nc
echo '#!/bin/bash' > "$MOCK_BIN/nc"
echo 'echo "Mock nc"' >> "$MOCK_BIN/nc"
chmod +x "$MOCK_BIN/nc"

export PATH="$PWD/$MOCK_BIN:$PATH"
TEST_HOME=$(mktemp -d)
export HOME="$TEST_HOME"

# Source the script first
SCRIPT_PATH="$PWD/anonymity.sh"
# Use || true because check_dependencies might exit if mock fails (though we mock nc now)
source "$SCRIPT_PATH" help &>/dev/null || true

# THEN Mock functions (overwriting the script's definitions)
function systemctl() {
  return 0
}
function sudo() {
  "$@"
}
function disable_all() {
  echo "DISABLE_TRIGGERED"
}

# Test Case 1: Decline confirmation
# Input sequence:
# 5 + Enter   -> Select Option 5
# no + Enter  -> Decline
# .           -> "Press any key"
# q + Enter   -> Quit
echo "Running Test Case 1: Decline confirmation..."
output_decline=$(printf "5\nno\n.q\n" | interactive_menu)

if [[ "$output_decline" == *"Are you sure"* ]]; then
  echo "✅ Prompt appeared."
else
  echo "❌ Prompt missing."
fi

if [[ "$output_decline" == *"DISABLE_TRIGGERED"* ]]; then
  echo "❌ disable_all triggered (Expected FAIL before fix)."
  exit 1
else
  echo "✅ disable_all NOT triggered."
fi

# Test Case 2: Accept confirmation
echo "Running Test Case 2: Accept confirmation..."
output_accept=$(printf "5\nyes\n.q\n" | interactive_menu)

if [[ "$output_accept" == *"DISABLE_TRIGGERED"* ]]; then
  echo "✅ disable_all triggered correctly."
else
  echo "❌ disable_all NOT triggered."
  exit 1
fi

rm -rf "$TEST_HOME"
rm -rf "$MOCK_BIN"
