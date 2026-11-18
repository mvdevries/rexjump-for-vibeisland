# Rule: git and pull requests

- **Changes go through a branch and a pull request, never directly to `main`.** Merge only when the maintainer
  says so.
- **Branch names start with the kind of change**: `breaking/…` (major version), `feature/…` (minor) or
  `fix/…` (patch, also for anything else). The release pipeline derives the version from the branch name of the
  merged pull request.
- Pull requests are **squash merged**, so the title of the pull request becomes the commit message on `main`
  and the release notes. Write it as a clear, short sentence.
- Commit messages, pull request titles and descriptions are in English (see the language rule).
- **No `Co-Authored-By` or any other Claude attribution** in commits or pull requests.
