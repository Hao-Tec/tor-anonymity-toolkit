#!/bin/bash
export HOME=$(mktemp -d)
CONF="$HOME/.anonymity.conf"

# Create a config file with 777 permissions
touch "$CONF"
chmod 777 "$CONF"

echo "Initial permissions: $(stat -c "%a" "$CONF")"

# Run the script (using absolute path to anonymity.sh)
REPO_ROOT=$(pwd)
"$REPO_ROOT/anonymity.sh" help > /dev/null 2>&1

# Check permissions
PERM=$(stat -c "%a" "$CONF")
echo "Final permissions: $PERM"

if [[ "$PERM" == "600" ]]; then
  echo "SUCCESS: Permissions fixed."
  exit 0
else
  echo "FAILURE: Permissions remain $PERM."
  exit 1
fi
