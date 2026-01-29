# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2026-01-29 - Tor Control Protocol Injection Fix
**Vulnerability:** The `newnym` function used `echo -e` to interpolate `AUTH_PASSWORD` into the Tor Control Protocol stream. This allowed a malicious password (e.g., containing `\r\nSIGNAL SHUTDOWN`) to inject arbitrary commands.
**Learning:** `echo -e` interprets escape sequences in its arguments, making it unsafe for handling untrusted data in protocols. Bash variable expansion happens before `printf`, so `printf` is safer but requires manual escaping of the target format's delimiters (quotes/backslashes).
**Prevention:** Use `printf` for protocol strings. Manually escape special characters (quotes, backslashes) in variables before interpolation.
