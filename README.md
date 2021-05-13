## Notes

- A standard merge like this is quite simple and easy to follow.
- Git history is preserved, but since the files are renamed, you can only fully view individual file history it with a `git log --follow <file path>`, and can't see it on GitHub.
- Since the move commits touch every file, we lose the last real contributors of each file.
- Commit SHAs are preserved. So any comments or tools referencing them or reverts that depend on the specific commit SHAs can still work.

See other branches for different approaches.
