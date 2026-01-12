# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-22 - Fix Tor Control Port Protocol Injection
**Vulnerability:** The `newnym` function used `echo -e` to interpolate `$AUTH_PASSWORD` into a Tor Control Protocol string. A crafted password containing double quotes and newlines could escape the quoted string and inject arbitrary commands (e.g., `SIGNAL SHUTDOWN`) to the Tor control port.
**Learning:** `echo -e` is unsafe for untrusted strings as it interprets escape sequences. Furthermore, blind interpolation into line-based protocols is dangerous even with quotes if newlines are not stripped or escaped.
**Prevention:** Always sanitize inputs for protocol commands. Use `printf` with format specifiers (e.g., `%s`) instead of `echo`. Explicitly escape protocol-sensitive characters (quotes, backslashes) and strip line terminators (`\r`, `\n`) from single-line arguments.
