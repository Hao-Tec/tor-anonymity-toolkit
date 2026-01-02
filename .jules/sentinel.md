# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-21 - Fixed Tor Control Port Command Injection via `echo -e`
**Vulnerability:** The script used `echo -e "AUTHENTICATE \"$AUTH_PASSWORD\"..."` to send commands to the Tor Control Port. Since `echo -e` interprets backslash escapes within the interpolated variable, a password containing characters like `\r\n` could inject arbitrary commands into the control stream (Command Injection).
**Learning:** `echo -e` is unsafe for constructing protocol messages when user input is included, as it interprets escapes in the input itself. `printf` is safer as it separates the format string from the data.
**Prevention:** Use `printf` for formatted output. Always sanitize inputs (escape quotes/backslashes) when constructing protocol messages manually, especially for line-based protocols.
