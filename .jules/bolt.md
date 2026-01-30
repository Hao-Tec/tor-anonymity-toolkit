# Bolt's Journal

## 2024-05-22 - Optimizing `newnym` execution
**Learning:** The `newnym` function contained broken logic (attempting to read an undefined file) and undefined variables (`exit_code`). Surprisingly, `[[ '' -eq 0 ]]` evaluates to true in Bash, masking the failure of the `exit_code` check.
**Action:** Always ensure variables used in conditionals are initialized. Use `set -u` (nounset) in scripts where possible to catch these issues early, though it might be too strict for existing loose scripts.

## 2024-05-22 - Bash Performance
**Learning:** `grep` is expensive for small string checks. Bash built-in `[[ string == *pattern* ]]` or regex `[[ string =~ regex ]]` is much faster as it avoids forking a new process.
**Action:** Replace `echo "$var" | grep "pattern"` with `[[ "$var" == *"pattern"* ]]` whenever possible.

## 2026-01-30 - Socket Performance
**Learning:** `nc -z` (netcat) is significantly slower (approx 3x) and requires an external dependency compared to Bash's built-in `/dev/tcp` for checking local ports. Additionally, relying on `nc` for status checks can cause failures in environments where `nc` is missing, even if Bash is present.
**Action:** Use `{ echo > /dev/tcp/host/port; } 2>/dev/null` for simple port availability checks in Bash scripts to improve speed and reduce dependencies.
