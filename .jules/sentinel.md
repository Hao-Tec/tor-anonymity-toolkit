# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-05-21 - Removed Hardcoded Tor Control Password
**Vulnerability:** The script contained a hardcoded default password ("ACILAB") for the Tor Control Port which was automatically written to the user's configuration file if it didn't exist. This encourages users to use weak/known credentials or accidentally expose their control port with a public password.
**Learning:** Default configurations should never contain secrets, even placeholders that look like real secrets. It creates a false sense of security and a known attack vector.
**Prevention:** Prompt the user for sensitive values during initialization. If interaction is not possible, use a safe, invalid placeholder (like "CHANGE_ME") and fail or warn until the user explicitly configures it.
