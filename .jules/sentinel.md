# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2025-12-24 - Protocol Injection via `echo -e` and Netcat
**Vulnerability:** The script used `echo -e` to construct the Tor Control Protocol command string, embedding the user-supplied `AUTH_PASSWORD` variable. This allowed for protocol injection if the password contained unescaped quotes or newlines (e.g., `pass"\nSIGNAL SHUTDOWN\n"`), as `echo -e` would interpret them or the shell would pass them raw, and the protocol would treat subsequent lines as new commands.
**Learning:** `echo -e` is unsafe for constructing protocol messages with untrusted or complex inputs because it doesn't automatically escape context-sensitive characters.
**Prevention:** Use `printf` for safer string formatting and explicitly escape characters (quotes, backslashes, newlines) required by the target protocol (Tor Control Protocol in this case) before construction.
