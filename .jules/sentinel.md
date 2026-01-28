# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2025-01-28 - Tor Control Protocol Injection Fix
**Vulnerability:** The `AUTH_PASSWORD` variable was interpolated directly into a Tor Control Protocol command string using `echo -e`. If the password contained double quotes or backslashes, it could break out of the quoted string and potentially inject arbitrary protocol commands (e.g., `SIGNAL NEWNYM`).
**Learning:** Shell command construction with untrusted or partially trusted variables requires strict sanitization. `echo -e` is particularly dangerous because it interprets backslashes. `printf` is safer but still requires escaping of quotes and backslashes when constructing quoted strings for other protocols.
**Prevention:** Always sanitize variables before embedding them in protocol commands. Use Bash parameter expansion `${var//pattern/replacement}` to escape special characters. Prefer `printf` over `echo -e` for precise control over output formatting.
