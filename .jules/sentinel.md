# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-22 - Prevented Protocol Injection in Tor Control
**Vulnerability:** The script used `echo -e` to send commands to the Tor Control Port, interpolating the `AUTH_PASSWORD` directly. If the password contained escaped characters or newlines (e.g., from a malicious config file), it could allow Command Injection via the Tor Control Protocol.
**Learning:** `echo -e` is unsafe for untrusted or complex strings because it interprets escape sequences. `printf` is safer. Also, Tor Control Protocol strings must be properly escaped (quotes and backslashes).
**Prevention:** Always use `printf` for protocol interactions. Explicitly sanitize variables before interpolation if the protocol uses delimiters like quotes or newlines.
