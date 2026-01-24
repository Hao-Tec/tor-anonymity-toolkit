# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-03-25 - Secured Tor Control Port Authentication
**Vulnerability:** The `newnym` function used `echo -e` to pipe the authentication command to `nc`. This allowed Tor Control Protocol injection because `$AUTH_PASSWORD` was interpolated directly without escaping backslashes or double quotes, potentially breaking the protocol's QuotedString format.
**Learning:** `echo -e` is unsafe for constructing protocols with untrusted or complex string data because it interprets backslash escapes.
**Prevention:** Use `printf` with format specifiers (`%s`) for data insertion. Explicitly escape protocol-specific characters (like `\` and `"`) before constructing the command string.
