#!/bin/bash
export PATH="$PWD/tests/mock_bin:$PATH"
export NO_COLOR=1

# Run anonymity.sh with piped input
# o: Select option 5
# n: Say 'no' to confirmation
# \n: Press any key to continue
# q: Quit
OUTPUT=$(printf "o\nn\n\nq\n" | ./anonymity.sh menu 2>&1)

# Debug: print output to stderr so we can see it if it fails
echo "$OUTPUT" >&2

ERRORS=0

# Check 1: Menu Label
# We expect: "5) Turn [o]ff Tor + NEWNYM"
if echo "$OUTPUT" | grep -F "Turn [o]ff Tor" >/dev/null; then
  echo "✅ Found new menu label."
else
  echo "❌ Missing or incorrect menu label."
  echo "Expected: 'Turn [o]ff Tor'"
  ERRORS=1
fi

# Check 2: Confirmation Prompt
# We expect: "Are you sure you want to disable anonymity?"
if echo "$OUTPUT" | grep -F "Are you sure you want to disable anonymity?" >/dev/null; then
  echo "✅ Found confirmation prompt."
else
  echo "❌ Missing confirmation prompt."
  ERRORS=1
fi

# Check 3: Cancellation
# We expect: "Action cancelled."
if echo "$OUTPUT" | grep -F "Action cancelled" >/dev/null; then
  echo "✅ Found cancellation message."
else
  echo "❌ Missing cancellation message."
  ERRORS=1
fi

if [[ $ERRORS -eq 0 ]]; then
  echo "🎉 All UX checks passed!"
  exit 0
else
  echo "🔥 Some checks failed."
  exit 1
fi
