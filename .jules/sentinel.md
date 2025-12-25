# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-12-25 - Prevented Tor Control Port Protocol Injection
**Vulnerability:** The script used `echo -e` to send commands to the Tor Control Port, interpolating `$AUTH_PASSWORD` directly without escaping. A malicious or complex password containing quotes or backslashes could break the protocol command structure or inject arbitrary commands (Protocol Injection).
**Learning:** When constructing protocol commands using shell scripts, simple variable interpolation is dangerous. Input data (like passwords) must be escaped according to the protocol's syntax (e.g., escaping quotes and backslashes) and tools like `printf` should be used for reliable control character handling.
**Prevention:** Always escape user-supplied data before including it in command strings. Use `printf` instead of `echo -e` for precise control over output format and to avoid shell-specific behavior.
