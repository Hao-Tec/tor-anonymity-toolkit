# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-20 - Fixed Protocol Injection in Tor Control Authentication
**Vulnerability:** The `newnym` function used `echo -e` to pipe commands to `nc`. This allowed an attacker (or user with a complex password) to inject Tor Control Protocol commands by including quoted strings or escape sequences (like `\r\n`) in the `AUTH_PASSWORD` variable, effectively breaking out of the `AUTHENTICATE` command.
**Learning:** `echo -e` is unsafe for untrusted or complex input because it interprets escape sequences. Even in simple shell scripts, protocol interactions must handle input sanitization (escaping quotes/backslashes) and avoid interpretation of control characters.
**Prevention:** Use `printf` for formatted output to separate data from format strings. Explicitly escape special characters (quotes, backslashes) in variables before using them in protocol contexts.
