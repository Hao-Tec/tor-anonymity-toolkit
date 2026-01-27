# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2026-01-27 - Fixed Tor Control Protocol Injection in newnym
**Vulnerability:** The `newnym` function used `echo -e` to construct the Tor Control Protocol command, interpolating `AUTH_PASSWORD` directly. A password containing double quotes or backslashes could break the protocol syntax or inject commands (e.g., `SIGNAL SHUTDOWN`).
**Learning:** `echo -e` interprets escape sequences in variables, making it unsafe for untrusted input in protocol strings. `printf` is safer as it separates format from data. Additionally, protocol-specific escaping (like backslashes for quotes) must be handled explicitly before insertion.
**Prevention:** Use `printf` instead of `echo -e` for constructing protocol commands. Always sanitize or escape user-provided strings according to the destination protocol's requirements (e.g., escaping `"` and `\` for Tor Control Port).
