# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2025-05-18 - Fixed Command Injection in Tor Control Authentication
**Vulnerability:** The `newnym` function used `echo -e` to send the authentication password to the Tor Control Port. The password variable was interpolated directly into the string, allowing command injection or protocol violation if the password contained double quotes or backslashes.
**Learning:** `echo -e` is unsafe for sending untrusted or complex data because it interprets escape sequences unpredictably. String interpolation without escaping is a common source of injection flaws.
**Prevention:** Use `printf` for precise control over output. Always escape special characters (quotes, backslashes) when interpolating variables into protocol strings.
