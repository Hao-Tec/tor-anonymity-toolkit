## 2025-05-18 - [CLI Transient Feedback]
**Learning:** Users perceive synchronous network operations (like `curl`) as "frozen" if they take >1s without feedback. In CLI tools, transient status lines that overwrite themselves (using `\r`) are a powerful pattern to provide reassurance without cluttering the final output log.
**Action:** For any blocking loop in a CLI that might wait on I/O, implement a `[ -t 1 ] && echo -ne "Status...\r"` pattern, ensuring to clear the line afterwards.
