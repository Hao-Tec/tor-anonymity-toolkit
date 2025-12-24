## 2024-05-22 - Keyboard Friendly Menu
**Learning:** CLI Menus that force numeric inputs can be cognitive friction. Adding mnemonic letter shortcuts (q=quit, s=status) is a low-cost high-value accessibility win for power users.
**Action:** Always map common actions (quit, help, status) to standard keys in interactive scripts.

## 2024-05-23 - Respecting User Environment
**Learning:** Command line tools often ignore the `NO_COLOR` standard, forcing users with accessibility needs or log-parsing requirements to deal with ANSI escape codes. Implementing `NO_COLOR` support is a simple but critical accessibility feature for CLI tools.
**Action:** Always check `NO_COLOR` env var before initializing color constants in shell scripts.

## 2024-05-24 - Feedback for Blocking Operations
**Learning:** For operations that involve network timeouts (like looping through IP checkers), users perceive a "hang" if there is no immediate feedback. Adding a transient "Trying [host]..." indicator that updates in-place reduces anxiety and makes the tool feel responsive.
**Action:** Always provide visual progress (even just text updates) for loops that perform blocking network calls.
