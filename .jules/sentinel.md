# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2026-02-04 - Protocol Injection via Shell Variables in `echo -e`
**Vulnerability:** The script used `echo -e` to send Tor Control Protocol commands, directly embedding the `AUTH_PASSWORD` variable. This allowed protocol injection via newlines (`\r\n`) in the password, enabling an attacker to execute arbitrary Tor commands.
**Learning:** `echo -e` interprets escape sequences in its arguments, and unescaped variables can alter the intended protocol structure.
**Prevention:** Use `printf` for strict format control and sanitize inputs (escape quotes/backslashes, remove newlines) before injecting them into protocol streams.
