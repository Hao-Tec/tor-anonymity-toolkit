# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2025-05-21 - Tor Control Protocol Injection via echo -e
**Vulnerability:** The script used `echo -e "AUTHENTICATE \"$AUTH_PASSWORD\"..." | nc` to send commands. This allowed command injection if the password contained double quotes or backslashes (interpreted by `echo -e` or breaking the quoted string).
**Learning:** `echo -e` should never be used to construct protocols with untrusted input. `printf` is safer but input must still be escaped for the target protocol (e.g. escaping `"` and `\` for Tor).
**Prevention:** Use `printf` and manually escape special characters (`\` and `"`) in variables before embedding them in protocol strings.
