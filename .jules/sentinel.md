# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-22 - Fixed Tor Control Protocol Injection and Hardcoded Password
**Vulnerability:** The script used `echo -e` to pipe commands to `nc`, which allowed injection of Tor Control commands if `AUTH_PASSWORD` contained newlines or backslashes. Additionally, the script generated a config file with a hardcoded default password ("ACILAB"), encouraging insecure deployments.
**Learning:** `echo -e` is unsafe for untrusted input as it interprets escapes. Protocol implementations must strictly escape or reject control characters (like `\r\n`) in data fields to prevent command injection. Default credentials should never be valid; force the user to configure them.
**Prevention:** Use `printf` for formatted output and strictly escape data before interpolation. Use "fail-secure" defaults (e.g., "CHANGE_ME") that prevent the application from starting until configured.
