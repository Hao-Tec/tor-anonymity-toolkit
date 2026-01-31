# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-23 - Fixed Tor Control Protocol Injection via echo -e
**Vulnerability:** The `newnym` function used `echo -e` to send commands to Tor Control Port, interpolating `$AUTH_PASSWORD` without escaping. This allowed protocol injection or authentication failure if the password contained double quotes, backslashes, or characters interpreted by `echo -e`.
**Learning:** `echo -e` is unsafe for sending arbitrary data strings because it interprets escape sequences. Interpolating unescaped user input into protocol command strings creates injection risks.
**Prevention:** Use `printf` for reliable output formatting. Always escape special characters (quotes, backslashes) when interpolating variables into structured text protocols.
