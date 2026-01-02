# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.
## 2025-03-24 - Secured Config Sourcing
**Vulnerability:** The script sourced `~/.anonymity.conf` without verifying its permissions. If this file were world-writable (666 or 777), a local attacker could modify it to inject arbitrary code which would be executed with the user's privileges when the script ran.
**Learning:** Always verify ownership and permissions of files before sourcing them in Bash, especially if they are in user-controlled locations.
**Prevention:** Added a pre-check using `stat -c "%a"` and forced `chmod 600` on the config file before loading it.
