## Notes

- While easy to do, it's not as simple as the standard merge.
- Git history is preserved, but it is rewritten, so it's a little risky to play with this.
- Since history is rewritten so that it looks like it was this way all along, we can easily see individual file history and authors from git locally and from github.
- Commit SHAs are not preserved. So any comments, tools referencing them or reverts that depend on the specific commit SHAs will not work.
- One risk of rewriting history is that contributors will be working in the old deprecated tree until they re-clone the repo. Since the contents are moved to a new repo, a fresh clone will be necessary anyways, so this isn't as much of a concern.
- Rewriting history means we can also rewrite some of our release tags to prevent collisions as they merge.

See other branches for different approaches.
