#!/bin/bash
set -eux

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

# Clone the two repos to merge 
git clone https://github.com/Caiopia/AppAuth-iOS.git
git clone https://github.com/Caiopia/bugsnag-cocoa.git

# Clone/create the repo to merge into. This one has a main branch with a single empty commit.
git clone https://github.com/Caiopia/repo-merge.git 

(cd AppAuth-iOS
  # TODO: something to make local copies of all remote branches?

  # Rewrite history to make it seem as if the repo's contents were always in a subdirectory.
  # --tag-rename prefixes the existing tags with the name of the repo.
  # Be really careful here, we likely never want to push these changes to the remote.
  # filter-repo removes the origin remote to help avoid this. 
  time git filter-repo --to-subdirectory-filter AppAuth-iOS/ --tag-rename '':'AppAuth-iOS'
)

# Move all contents into subdirectory of repo 2
(cd bugsnag-cocoa
  # TODO: something to make local copies of all remote branches?
  
  # Rewrite history to make it seem as if the repo's contents were always in a subdirectory.
  # --tag-rename prefixes the existing tags with the name of the repo.
  # Be really careful here, we likely never want to push these changes to the remote.
  # filter-repo removes the origin remote to help avoid this.
  time git filter-repo --to-subdirectory-filter bugsnag-cocoa/ --tag-rename '':'bugsnag-cocoa'
)

# Merge both repos
(cd repo-merge

  # Add local repos as remotes, --tags brings the tags, -f fetches the remotes.
  git remote add --tags -f AppAuth-iOS ../AppAuth-iOS
  git remote add --tags -f bugsnag-cocoa ../bugsnag-cocoa

  # Checkout branch
  git checkout -b filter-repo-merge

  # Merge allowing unrelated histories. 
  git merge AppAuth-iOS/master --allow-unrelated-histories
  git merge bugsnag-cocoa/master --allow-unrelated-histories

  # Remove remotes just to prevent accidentally pushing to them
  git remote rm AppAuth-iOS
  git remote rm bugsnag-cocoa

  # Copy this script into the repo
  cp $SCRIPT_PATH .

  # Write some notes to README.md
  notes=("## Notes"
    ""
    " - While easy to do, it's not as simple as the standard merge."
    " - Git history is preserved, but it is rewritten, so it's a little risky to play with this."
    " - Since history is rewritten so that it looks like it was this way all along, we can easily see individual file history and authors from git locally and from github."
    " - Commit SHAs are not preserved. So any comments, tools referencing them or reverts that depend on the specific commit SHAs will not work."
    " - One risk of rewriting history is that contributors will be working in the old deprecated tree until they re-clone the repo. Since the contents are moved to a new repo, a fresh clone will be necessary anyways, so this isn't as much of a concern."
    " - Rewriting history means we can also rewrite some of our release tags to prevent collisions as they merge."
    ""
    "See other branches for different approaches.")
  
  for l in "${notes[@]}"; do
    echo -e $l >> README.md;
  done;

  git add .
  git commit -m 'Copy script into repo for reference; Add README'

  # TODO: Push to remote outside of this. Might need to split it into multiple pushes depending on repo size.
)
