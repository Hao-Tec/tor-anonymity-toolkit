## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2025-02-19 - Fixed Command Injection via `echo -e` in Protocol Stream
**Vulnerability:** The `newnym` function used `echo -e "AUTHENTICATE \"$AUTH_PASSWORD\"..."` to send commands to the Tor Control Port. If `$AUTH_PASSWORD` contained `\n`, `echo -e` interpreted it as a newline, allowing an attacker (or malformed config) to inject arbitrary Tor Control commands (e.g., `SIGNAL SHUTDOWN`).
**Learning:** `echo -e` is dangerous when handling untrusted or arbitrary strings because it interprets escape sequences within variables. `printf` is safer as it treats arguments as literal strings. Additionally, protocols requiring quoted strings (like Tor Control) need explicit escaping of backslashes and quotes.
**Prevention:** Always use `printf` instead of `echo -e` when constructing protocol streams. Manually escape special characters (quotes, backslashes, newlines) when inserting variables into quoted protocol fields.
