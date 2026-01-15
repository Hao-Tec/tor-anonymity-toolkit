# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-10-27 - Tor Control Protocol Injection via AUTH_PASSWORD
**Vulnerability:** The `newnym` function constructed Tor Control Protocol commands using `echo -e` with the `AUTH_PASSWORD` variable. This allowed protocol injection if the password contained unescaped backslashes, double quotes, or newlines, potentially breaking the command structure or injecting arbitrary commands.
**Learning:** Tor Control Protocol uses a specific quoted string format (double quotes with backslash escapes) that is not compatible with standard shell escaping (`printf %q`). `echo -e` is unsafe for untrusted input in protocol streams.
**Prevention:** Explicitly sanitize variables used in protocol commands by escaping backslashes, double quotes, and control characters (newlines/CRs). Use `printf` with format strings to strictly separate data from protocol keywords.
