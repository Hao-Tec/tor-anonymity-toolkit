# Bolt's Journal

## 2024-05-22 - Optimizing `newnym` execution
**Learning:** The `newnym` function contained broken logic (attempting to read an undefined file) and undefined variables (`exit_code`). Surprisingly, `[[ '' -eq 0 ]]` evaluates to true in Bash, masking the failure of the `exit_code` check.
**Action:** Always ensure variables used in conditionals are initialized. Use `set -u` (nounset) in scripts where possible to catch these issues early, though it might be too strict for existing loose scripts.

## 2024-05-22 - Bash Performance
**Learning:** `grep` is expensive for small string checks. Bash built-in `[[ string == *pattern* ]]` or regex `[[ string =~ regex ]]` is much faster as it avoids forking a new process.
**Action:** Replace `echo "$var" | grep "pattern"` with `[[ "$var" == *"pattern"* ]]` whenever possible.

## 2024-05-22 - Optimizing `tput` with `printf`
**Learning:** `tput` is significantly slower than Bash builtin `printf` (~78x slower for simple cursor operations) due to process spawning. For scripts with high-frequency UI updates (like spinners), using direct ANSI escape codes via `printf` is a massive win.
**Action:** Replace `tput civis`/`cnorm` with `printf '\033[?25l'`/`\033[?25h'` when standard ANSI support is assumed.

## 2024-05-22 - Optimizing `read -p` subshells
**Learning:** Using `read -p "$(echo -e ...)"` creates a subshell for every prompt. By defining colors with ANSI-C quoting (`$'\e...'`), variables can be passed directly to `read -p`, eliminating the subshell fork.
**Action:** Use `VAR=$'\e[...'` for color definitions to allow direct usage in prompts.
