# Rule: comments in code

- **Never add comments to code.** Do not add comments or docstrings in any language or file type (Swift,
  shell, YAML, config, templates). Let the code explain itself with small functions and descriptive names: too
  verbose is better than not clear enough.
- **Leave existing comments alone.** Do not change or remove them, even if they look outdated or sit next to
  your change. This includes the step headings in `build.sh` and `install.sh`. Tell the maintainer instead of
  editing them yourself.
- Explanations belong in the pull request description, the README or your answer in the chat, not in the code.
