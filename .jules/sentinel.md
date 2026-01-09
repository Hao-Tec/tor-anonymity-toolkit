# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2025-05-17 - Fixed Tor Control Port Injection via AUTH_PASSWORD
**Vulnerability:** The `AUTH_PASSWORD` variable was interpolated into a `printf` format string (or previously `echo -e`) without full escaping. While double quotes and backslashes were being escaped, newlines (`\n`) and carriage returns (`\r`) were not. Since the Tor Control Protocol is line-based, an attacker controlling the password (e.g., via config file or env var) could inject malicious commands (like `SIGNAL SHUTDOWN`) by embedding newlines in the password.
**Learning:** When interpolating data into line-based protocols (like SMTP, HTTP, Tor Control), strictly sanitize or escape all line-ending characters (`\r`, `\n`) in addition to protocol-specific delimiters (like quotes).
**Prevention:** Always escape CRLF in user-controlled input before sending it to a socket. Use rigorous escaping libraries or functions where available. In Bash, `${var//$'\n'/\\n}` is a useful pattern.
