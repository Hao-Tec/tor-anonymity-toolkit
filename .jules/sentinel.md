# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-22 - Fixed Tor Control Protocol Injection via AUTH_PASSWORD
**Vulnerability:** The script used `echo -e` to pipe commands to the Tor Control Port, interpolating `AUTH_PASSWORD` directly. This allowed a malicious password (e.g. from a compromised config) to inject arbitrary Tor control commands using `\r\n` sequences and quote manipulation.
**Learning:** `echo -e` is dangerous for protocol interaction when including user-controlled data because it interprets escape sequences. Unsanitized variable interpolation in line-based protocols is a classic injection vector.
**Prevention:** Use `printf` with format specifiers (e.g., `%s`) for safe string output. Explicitly sanitize and escape special characters (quotes, backslashes) when constructing protocol messages manually.
