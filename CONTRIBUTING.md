# Contributing

Thanks for wanting to help. This is a small project, so keep changes small too.

## Working on the code

- You need macOS, Xcode or the command line tools, Vibe Island and Rex Beta.
- `./build.sh` builds the app, `./install.sh` installs and starts it. See `README.md` for details and for the log you can use to see what a jump did.
- The code is plain Swift without dependencies. Keep functions small and let names explain the code: do not add comments or docstrings.
- The working language is English: code, log lines, docs, commit messages and pull requests.

## Pull requests

- Branch from `main` and open a pull request; the maintainer merges.
- Describe what changed and why. Mention how you tested it, for example with `open "rexjump://focus?pid=&tty=%2Fdev%2Fttys001"` and the log.
- Do not add names or logos of other products as artwork, and do not put personal data such as e-mail addresses in commits or files. Use your GitHub noreply address for commits.

## Reporting problems

Open an issue with the macOS version, the Vibe Island and Rex versions and the relevant lines from `~/Library/Logs/rexjump-for-vibeisland.log`. For security problems, see `SECURITY.md`.
