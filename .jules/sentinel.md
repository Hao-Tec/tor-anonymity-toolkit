# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2026-02-03 - Prevented Tor Control Protocol Injection
**Vulnerability:** The `newnym` function used `echo -e` and unescaped variable interpolation to send commands to the Tor Control Port. This allowed a malicious or complex password (containing `"` or `\`) to malform the protocol command (Protocol Injection).
**Learning:** Even when not using a shell, protocol command injection is possible if user input is interpolated directly into command strings without escaping protocol-specific delimiters (like quotes in Tor Control Protocol). `echo -e` is risky for arbitrary data as it interprets backslashes.
**Prevention:** Always escape user input according to the destination protocol's syntax. Use `printf` instead of `echo -e` to treat data as literal strings.
