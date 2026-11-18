# Rule: tests

- There is no automated test suite yet. Every change is tried by hand: build with `./build.sh`, do a jump with
  `open "rexjump://focus?pid=&tty=%2Fdev%2Fttys001"` using the tty of a real session, and read
  `~/Library/Logs/rexjump-for-vibeisland.log`.
- A real click in Vibe Island cannot be tested from the terminal. Say so when you could not try a change that
  way.
- The pull request pipeline builds and validates the app; it must pass.
