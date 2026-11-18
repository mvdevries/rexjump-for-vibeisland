# Rule: code style

- Keep functions small and let them do one thing. A name describes what the function does; too verbose is
  better than not clear enough.
- Plain Swift without dependencies, built with `swiftc` through `build.sh`. Keep one type or concern per file.
- `JumpHandler` is the only place that ties the steps of a jump together; the other files each do one step.
- A jump that finds no matching pane does nothing. Never open a new pane or focus a wrong one.
- Log lines are short English sentences; the log is how a jump is debugged.
