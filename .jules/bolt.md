# Bolt's Journal

## 2024-05-22 - Optimizing `newnym` execution
**Learning:** The `newnym` function contained broken logic (attempting to read an undefined file) and undefined variables (`exit_code`). Surprisingly, `[[ '' -eq 0 ]]` evaluates to true in Bash, masking the failure of the `exit_code` check.
**Action:** Always ensure variables used in conditionals are initialized. Use `set -u` (nounset) in scripts where possible to catch these issues early, though it might be too strict for existing loose scripts.

## 2024-05-22 - Bash Performance
**Learning:** `grep` is expensive for small string checks. Bash built-in `[[ string == *pattern* ]]` or regex `[[ string =~ regex ]]` is much faster as it avoids forking a new process.
**Action:** Replace `echo "$var" | grep "pattern"` with `[[ "$var" == *"pattern"* ]]` whenever possible.

## 2025-05-22 - TCP Check Optimization
**Learning:** Using `nc -z` for local port checks spawns an external process. Bash built-in `( > /dev/tcp/host/port )` is approximately 3x faster and removes the runtime dependency on `netcat` for simple status checks.
**Action:** Replace `nc -z host port` with `( > /dev/tcp/host/port ) 2>/dev/null` where applicable, ensuring timeout behavior is acceptable (instant for localhost).
