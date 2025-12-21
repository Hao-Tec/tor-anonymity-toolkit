## 2024-05-22 - Keyboard Friendly Menu
**Learning:** CLI Menus that force numeric inputs can be cognitive friction. Adding mnemonic letter shortcuts (q=quit, s=status) is a low-cost high-value accessibility win for power users.
**Action:** Always map common actions (quit, help, status) to standard keys in interactive scripts.

## 2024-05-23 - Respecting User Environment
**Learning:** Command line tools often ignore the `NO_COLOR` standard, forcing users with accessibility needs or log-parsing requirements to deal with ANSI escape codes. Implementing `NO_COLOR` support is a simple but critical accessibility feature for CLI tools.
**Action:** Always check `NO_COLOR` env var before initializing color constants in shell scripts.

## 2024-05-24 - Hidden Affordances
**Learning:** Hidden shortcuts confuse users. If a feature exists (like 's' for status), the UI must explicitly show it (e.g., "Show Status [s]"). Hidden power-user features often go unused or require users to read source code.
**Action:** Visually expose all supported keyboard shortcuts in menu interfaces.
