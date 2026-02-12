# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-23 - [Insecure Config File Permissions]
**Vulnerability:** The configuration file `~/.anonymity.conf` is sourced by the script without checking permissions. If created with or changed to world-writable permissions (e.g., 666 or 777), any user on the system could inject malicious commands that would be executed with the privileges of the user running `anonymity.sh`.
**Learning:** Sourcing files in shell scripts (`source` or `.`) is effectively code execution. Always verify that sourced files are not writable by other users before loading them.
**Prevention:** Use `stat` to check file permissions before sourcing. Enforce `600` (read/write by owner only) or `400` (read only by owner) for any configuration file that contains secrets or is sourced.
