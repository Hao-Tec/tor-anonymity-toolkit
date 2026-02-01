# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-22 - Fixed Tor Control Protocol Injection
**Vulnerability:** The `newnym` function used `echo -e` to pipe commands to `nc`, allowing `AUTH_PASSWORD` to inject arbitrary protocol commands (CRLF injection) via escape sequences like `\r\n`.
**Learning:** `echo -e` expands escape sequences in variables, making it unsafe for untrusted input. `printf` with `%s` treats arguments as literal strings, preventing this injection.
**Prevention:** Always use `printf` instead of `echo -e` when dealing with variables in protocol strings. Explicitly escape special characters (quotes, backslashes) required by the target protocol.
