# Contributing

Thanks for your interest in RexJump for VibeIsland. Bug reports, ideas and pull requests are welcome. This is a
small hobby project, so replies can take a few days.

## Language

Everything in this repository is in English: code, log lines, commit messages, pull requests, issues and
documentation.

## Before you start

- Open an issue first for anything bigger than a small fix, so we can agree on the approach.
- Never put personal data such as e-mail addresses, home paths or machine names in issues, commits or code. Use
  your GitHub noreply address for commits.
- Do not add names or logos of other products as artwork. Plain-text mentions of Vibe Island and Rex are fine.

## Setting up

You need macOS, Xcode or the command line tools, Vibe Island and Rex Beta. There are no dependencies.

## Making a change

1. Branch from `main`. The branch name starts with the kind of change, because the release pipeline derives
   the version from it:
   - `breaking/…` for a change that breaks existing users (major version)
   - `feature/…` for a new feature (minor version)
   - `fix/…` for a fix or anything else (patch version)
2. Keep the code style of the project:
   - small functions that do one thing, with descriptive names (too verbose is better than not clear enough)
   - **no comments or docstrings in code**: explain in the pull request or the README instead
3. Build and try it: `./build.sh` builds the app and `./install.sh` installs and starts it. Do a jump by hand
   with `open "rexjump://focus?pid=&tty=%2Fdev%2Fttys001"` and read `~/Library/Logs/rexjump-for-vibeisland.log`.
4. Open a pull request against `main` with a clear title (it becomes the release notes) and a description of
   what changed and why. The pull request checks must pass.

Pull requests are squash merged, so the title of the pull request becomes the commit message on `main`.

## Pipelines and releases

- **Pull request** (`.github/workflows/pull-request.yml`): checks the branch name, builds and validates the app
  on macOS and uploads the built app as an artifact of the run.
- **Release** (`.github/workflows/release.yml`): on every merge to `main` that changes the app (not only docs
  or workflows) it determines the version, runs the same checks, builds the app with that version, zips it and
  creates a tag and GitHub release with the zip and `rex.json` attached.
- **Dependabot** updates the GitHub Actions weekly. Minor and patch updates arrive in one pull request, and
  major updates in a separate one so they can be reviewed on their own.

The version comes from the branch name of the merged pull request:

| Branch name   | Version bump |
|---------------|--------------|
| `breaking/…`  | major        |
| `feature/…`   | minor        |
| `fix/…`       | patch        |

The pipeline raises the latest `v<version>` tag by that kind of version. The title of the pull request becomes
the squash commit title and the release notes. The version in `Info.plist` is filled in during the build and
is not committed.

To build a release by hand:

```
VERSION=1.2.3 ./build.sh
ditto -c -k --keepParent "RexJump for VibeIsland.app" RexJump-for-VibeIsland-1.2.3.zip
```

Without `VERSION` the app is built as `0.0.0-dev`.

## Reporting problems

Open an issue with the macOS version, the Vibe Island and Rex versions and the relevant lines from
`~/Library/Logs/rexjump-for-vibeisland.log`.

## Reporting security problems

Please follow [SECURITY.md](SECURITY.md) and do not open a public issue.
