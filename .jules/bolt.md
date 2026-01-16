# Bolt's Journal

## 2024-05-22 - Optimizing `newnym` execution
**Learning:** The `newnym` function contained broken logic (attempting to read an undefined file) and undefined variables (`exit_code`). Surprisingly, `[[ '' -eq 0 ]]` evaluates to true in Bash, masking the failure of the `exit_code` check.
**Action:** Always ensure variables used in conditionals are initialized. Use `set -u` (nounset) in scripts where possible to catch these issues early, though it might be too strict for existing loose scripts.

## 2024-05-22 - Bash Performance
**Learning:** `grep` is expensive for small string checks. Bash built-in `[[ string == *pattern* ]]` or regex `[[ string =~ regex ]]` is much faster as it avoids forking a new process.
**Action:** Replace `echo "$var" | grep "pattern"` with `[[ "$var" == *"pattern"* ]]` whenever possible.

## 2026-01-16 - Caching in Monitor Loops
**Learning:** `monitor_loop` was fetching the static "Real IP" on every iteration, creating unnecessary network overhead and risk of hanging.
**Action:** Cache static data outside of infinite loops. Ensure all external network requests (like `curl`) have explicit timeouts (`--max-time`) to prevent blocking the loop indefinitely.
