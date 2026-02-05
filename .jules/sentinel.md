# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2025-05-20 - Tor Control Protocol Injection Fix
**Vulnerability:** The `newnym` function used `echo -e` to pipe `AUTH_PASSWORD` to `nc`. This allowed command injection if the password contained `\r\n` characters (e.g. `password"\r\nSIGNAL SHUTDOWN`).
**Learning:** `echo -e` is dangerous for untrusted input in protocol streams because it interprets escape characters in the expanded variable.
**Prevention:** Use `printf` with format strings (`printf "%s" "$var"`) to strictly separate data from protocol control characters, and sanitize inputs (escape quotes/backslashes) when generating QuotedStrings for protocols.
