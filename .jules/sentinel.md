# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-22 - Sanitize Tor Control Password
**Vulnerability:** The `newnym` function interpolated `$AUTH_PASSWORD` directly into an `echo -e` command string piped to `nc`. If the password contained double quotes or backslashes, it could break the Tor Control Protocol quoted string format, leading to command injection or authentication failure.
**Learning:** Even when using simple tools like `nc`, constructing protocol strings with shell variable interpolation is risky. Tor Control Protocol requires strict quoting. `echo -e` behavior with backslashes is also tricky and less portable than `printf`.
**Prevention:** Always sanitize user inputs before using them in protocol strings. Use `printf` for safer string formatting. Escape special characters according to the target protocol's specification (in this case, backslashes and double quotes).
