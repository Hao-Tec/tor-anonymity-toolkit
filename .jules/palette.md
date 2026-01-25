## 2024-05-23 - [CLI Menu Mnemonics]
**Learning:** CLI menus with number-only selection are cognitively slower. Adding mnemonic shortcuts (e.g., `[t]oggle` vs `1`) significantly improves navigation speed for power users.
**Action:** When designing CLI menus, always implement and highlight single-key mnemonics (using brackets `[k]ey`) and support them in the `case` statement.
## 2024-05-22 - Keyboard Friendly Menu
**Learning:** CLI Menus that force numeric inputs can be cognitive friction. Adding mnemonic letter shortcuts (q=quit, s=status) is a low-cost high-value accessibility win for power users.
**Action:** Always map common actions (quit, help, status) to standard keys in interactive scripts.

## 2024-05-23 - Respecting User Environment
**Learning:** Command line tools often ignore the `NO_COLOR` standard, forcing users with accessibility needs or log-parsing requirements to deal with ANSI escape codes. Implementing `NO_COLOR` support is a simple but critical accessibility feature for CLI tools.
**Action:** Always check `NO_COLOR` env var before initializing color constants in shell scripts.

## 2024-05-24 - Feedback for Blocking Operations
**Learning:** For operations that involve network timeouts (like looping through IP checkers), users perceive a "hang" if there is no immediate feedback. Adding a transient "Trying [host]..." indicator that updates in-place reduces anxiety and makes the tool feel responsive.
**Action:** Always provide visual progress (even just text updates) for loops that perform blocking network calls.
## 2025-02-17 - Reducing Friction in CLI Navigation
**Learning:** Requiring "Enter" to continue flow is a minor friction point that adds up. "Press any key" feels significantly snappier and more responsive for simple acknowledgments.
**Action:** Use `read -n 1 -s -r` for pause/continue prompts instead of standard `read`.

## 2025-02-18 - Destructive Action Safety
**Learning:** In CLI menus, destructive actions (like disabling services) are prone to accidental triggering if placed alongside benign navigation commands. Users scan numbers quickly.
**Action:** Always guard destructive CLI menu options with a `[y/N]` confirmation prompt and use distinct mnemonics (e.g., `Turn [o]ff` vs `[d]isable` if `d` is for dashboard).
