# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2026-01-17 - Secure Config Sourcing
**Vulnerability:** The script sourced `~/.anonymity.conf` without verifying file permissions. If the file was world-writable, other users could inject arbitrary commands which would run with the victim's privileges.
**Learning:** Sourcing files is effectively executing code. Always verify ownership and permissions of files before sourcing them, especially in user directories where permissions might be loose.
**Prevention:** Enforce `chmod 600` (or stricter) on configuration files before `source`. Use `stat -c "%a"` (Linux) or portable alternatives to verify.
