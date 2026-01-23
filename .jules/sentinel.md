# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-22 - Fixed Protocol Injection in Tor Control
**Vulnerability:** The `newnym` function used `echo -e` to send the authentication password to the Tor Control Port. This allowed for protocol injection if the password contained double quotes or backslashes, as `echo -e` does not perform contextual escaping and interprets backslashes.
**Learning:** `echo -e` should never be used to construct protocol messages containing untrusted or variable input, especially when that input can contain escape characters or delimiters (like quotes).
**Prevention:** Use `printf` for formatted output as it separates the format string from the data. Always manually escape data (e.g., `"` and `\`) when constructing raw protocol strings that use these characters as delimiters.
