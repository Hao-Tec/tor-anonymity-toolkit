# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2026-01-18 - Fixed Hardcoded Password and Protocol Injection
**Vulnerability:** The script contained a hardcoded default Tor Control Port password ("ACILAB") and was vulnerable to Tor Control Protocol injection. The `newnym` function used `echo -e` to interpolate the password into a command string without escaping, allowing a malicious password (via config) to inject arbitrary Tor commands (e.g., `SIGNAL SHUTDOWN`).
**Learning:** Interpolating variables directly into protocol strings without sanitization allows injection attacks. `echo -e` interprets escaped characters (like `\n`) in variables, which can break protocol boundaries.
**Prevention:** Always escape user input before including it in protocol commands. Use `printf` instead of `echo -e` to avoid implicit escape interpretation. Do not ship default secrets in code.
