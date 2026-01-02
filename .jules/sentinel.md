## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2025-05-15 - Secured Tor Control Port Interaction
**Vulnerability:** The `newnym` function used `echo -e` to construct the Tor Control Protocol commands. If the password contained double quotes or backslashes, it could break the protocol syntax or allow command injection, as `echo -e` interprets backslashes and quotes were not escaped.
**Learning:** `echo -e` is risky for handling untrusted or complex strings because it processes escape sequences. `printf` is much safer as it separates format from data. Protocols requiring quoting (like Tor's) need explicit escaping of the quote character and escape character itself.
**Prevention:** Use `printf` instead of `echo -e` for protocol interactions. Always escape input variables according to the protocol's syntax (e.g., escaping `"` and `\` for quoted strings).
