#!/bin/bash

# Setup mocks
mkdir -p tests/mock_bin
echo '#!/bin/sh' > tests/mock_bin/nc
echo 'exit 0' >> tests/mock_bin/nc

echo '#!/bin/sh' > tests/mock_bin/systemctl
echo 'exit 0' >> tests/mock_bin/systemctl

echo '#!/bin/sh' > tests/mock_bin/sudo
echo '$@' >> tests/mock_bin/sudo

chmod +x tests/mock_bin/nc tests/mock_bin/systemctl tests/mock_bin/sudo
export PATH="$PWD/tests/mock_bin:$PATH"

# Function to run the menu with input
run_menu() {
    local input="$1"
    # Use timeout to prevent infinite loops if logic is wrong
    timeout 5s ./anonymity.sh menu <<< "$(echo -e "$input")" 2>&1
}

echo "--- TEST 1: Check Menu Label ---"
# Just 'q' to quit
output=$(run_menu "q")
if echo "$output" | grep -q "5) Turn \[o\]ff Tor + NEWNYM"; then
    echo "✅ Label is correct"
else
    echo "❌ Label is incorrect (Expected 'Turn [o]ff...', found something else)"
    echo "$output" | grep "5)"
fi

echo "--- TEST 2: Check Confirmation (Cancel) ---"
# Select 5, then n.
# We need to handle the "Press any key" after 5.
# Sequence:
# 1. Menu prompts choice. Input: 5
# 2. Case 5 runs. (Proposed: Prompts confirm). Input: n
# 3. Case 5 finishes.
# 4. "Press any key". Input: \n (empty line or just a char)
# 5. Menu loops. Prompts choice. Input: q
#
# So input string should be: "5\nn\n\nq" ?
# Wait.
# `<<<` feeds the string.
# If I use `echo -e "5\nn\n\nq"`, it sends:
# 5
# n
# (newline)
# q
#
# Let's trace carefully.
# Current logic (before fix):
# Input: "5\nn\nq"
# 1. Read choice: "5" (read -p reads line)
# 2. Case 5: disable_all. (No confirm prompt yet)
# 3. Press any key: reads "n" (read -n 1)
# 4. Loop.
# 5. Read choice: "" (empty line after n?) or just newline?
#    If I echo -e "5\nn", it is "5\n" then "n\n".
#    read -p reads until newline. So it reads "5".
#    Then "n" is left.
#    read -n 1 reads "n".
#    Loop.
#    Read choice: reads next line. If "n\nq", next is "q".
#    Choice is q. Exit.
#
# So "5\nn\nq" works for current logic.
#
# Future logic (with fix):
# 1. Read choice: "5"
# 2. Case 5: Prompt confirm. Read "n".
# 3. Press any key. Read next char.
#    If input is "5\nn\n\nq"
#    "5" (choice)
#    "n" (confirm)
#    "\n" (any key)
#    "q" (next choice)
#
# So I need enough inputs.
# I will use ample newlines just in case.
# "5\nn\n\n\nq"

output=$(run_menu "5\nn\n\n\nq")

if echo "$output" | grep -q "Are you sure you want to disable anonymity services?"; then
    echo "✅ Confirmation prompt appeared"
else
    echo "❌ Confirmation prompt did NOT appear"
fi

if echo "$output" | grep -q "Disabling Tor and NEWNYM timer"; then
    echo "❌ Action executed despite 'n'"
else
    echo "✅ Action cancelled correctly"
fi

echo "--- TEST 3: Check Confirmation (Confirm) ---"
# Select 5, then y.
# Input: "5\ny\n\n\nq"
output=$(run_menu "5\ny\n\n\nq")

if echo "$output" | grep -q "Disabling Tor and NEWNYM timer"; then
    echo "✅ Action executed on 'y'"
else
    echo "❌ Action NOT executed despite 'y'"
fi
