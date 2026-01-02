# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2025-05-27 - Secure Tor Control Protocol Injection
**Vulnerability:** The `newnym` function used `echo -e` to send the authentication password to the Tor Control Port. This was vulnerable to injection or protocol breakage if the password contained double quotes or backslashes, as `echo -e` does not safely handle arbitrary strings in this context.
**Learning:** `echo -e` is unsafe for transmitting untrusted or complex data in protocols because it interprets escape sequences and relies on shell quoting.
**Prevention:** Use `printf` with explicit format strings and manually escape special characters (quotes, backslashes) when constructing protocol messages in Bash.
