# Security policy

## Reporting a vulnerability

Please do not open a public issue for a security problem. Use GitHub's private vulnerability reporting instead: open the **Security** tab of this repository and choose **Report a vulnerability**.

Include what you found, how to reproduce it and which version of the app you used. You get a reply as soon as the maintainer can look at it.

## Scope

The app only listens for `rexjump://` URLs on the local Mac and talks to the local Rex server through its unix socket. It makes no network connections and stores nothing except a log file in `~/Library/Logs`.
