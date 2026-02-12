# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-22 - Fixed Protocol Injection in Tor Control via `printf`
**Vulnerability:** The `newnym` function used `echo -e` to pipe commands to `nc`. This allowed interpreted characters (like backslashes) in the `AUTH_PASSWORD` to be mangled or, if crafted maliciously, to potentially inject protocol commands if not properly escaped. `echo -e` behavior is also inconsistent across shells.
**Learning:** `echo -e` should never be used for constructing protocol payloads that include user-supplied or configuration-supplied data. The behavior of backslashes is dangerous.
**Prevention:** Use `printf` for protocol interactions. Sanitize inputs by explicitly escaping special characters (backslashes and quotes for Tor Control Protocol) before interpolation.
