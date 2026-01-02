# Sentinel Journal

## 2024-03-24 - Replaced expect/telnet with netcat for Tor Control
**Vulnerability:** The script used `expect` and `telnet` to interact with the Tor Control Port. The `expect` script interpolated `$AUTH_PASSWORD` directly into the script string, creating a potential injection vulnerability if the password contained special characters. Additionally, `telnet` and `expect` are unnecessary dependencies that increase the attack surface.
**Learning:** `expect` scripts are difficult to secure when variables are interpolated. It's better to use simpler tools like `nc` (netcat) for simple socket interactions.
**Prevention:** Avoid `expect` for simple protocols. Use `nc` or dedicated clients. Validate inputs before interpolation if interpolation is unavoidable.

## 2024-03-24 - Use printf for Tor Control Protocol
**Vulnerability:** Using `echo -e` to pipe commands to `nc` allows for command injection if the variables (like `$AUTH_PASSWORD`) contain escape sequences or control characters that `echo -e` interprets.
**Learning:** `printf` is safer than `echo -e` for constructing protocol messages because it separates the format string from the data arguments, preventing data from being interpreted as control characters or formatting directives.
**Prevention:** Always use `printf "FORMAT" "ARGS"` when constructing messages for external protocols or pipes, especially when including user-controlled or variable data.
