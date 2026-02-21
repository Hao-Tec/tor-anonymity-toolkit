#!/bin/bash
OUTPUT=$(echo "q" | ./anonymity.sh menu)
if echo "$OUTPUT" | grep -F "Turn [o]ff Tor + NEWNYM"; then
  echo "Verified: Found 'Turn [o]ff Tor + NEWNYM'"
  exit 0
else
  echo "Verification Failed: 'Turn [o]ff Tor + NEWNYM' not found"
  echo "Output was:"
  echo "$OUTPUT"
  exit 1
fi
