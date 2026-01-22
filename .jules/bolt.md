# Bolt's Journal

## 2024-05-22 - Optimizing `newnym` execution
**Learning:** The `newnym` function contained broken logic (attempting to read an undefined file) and undefined variables (`exit_code`). Surprisingly, `[[ '' -eq 0 ]]` evaluates to true in Bash, masking the failure of the `exit_code` check.
**Action:** Always ensure variables used in conditionals are initialized. Use `set -u` (nounset) in scripts where possible to catch these issues early, though it might be too strict for existing loose scripts.

## 2024-05-22 - Bash Performance
**Learning:** `grep` is expensive for small string checks. Bash built-in `[[ string == *pattern* ]]` or regex `[[ string =~ regex ]]` is much faster as it avoids forking a new process.
**Action:** Replace `echo "$var" | grep "pattern"` with `[[ "$var" == *"pattern"* ]]` whenever possible.

## 2026-01-22 - Replacing nc with /dev/tcp
**Learning:** For checking local ports, Bash's built-in `/dev/tcp/host/port` is significantly faster (no process fork) than `nc -z`. It also reduces external dependencies.
**Action:** Prefer `{ echo > /dev/tcp/host/port; } 2>/dev/null` over `nc -z host port` for simple connectivity checks, especially in loops.

## 2026-01-22 - Fail-Fast in Monitoring Loops
**Learning:** Network monitoring loops that use expensive tools like `curl` should always have a cheap "fail-fast" check (like a port check) at the start. This prevents hanging on timeouts when the service is down.
**Action:** Guard `curl` calls with a local service check if possible.
