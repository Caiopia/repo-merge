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
  git checkout -b nested-directory
  mkdir nested-directory

  # Move all repo contents into nested-directory (except for nested-directory itself)
  find . -mindepth 1 -maxdepth 1 -not -name nested-directory -exec git mv {} nested-directory/ \;
  
  # Rename directory, add, and commit.
  mv nested-directory AppAuth-iOS
  git add .
  git commit -m 'Move AppAuth-iOS into subdirectory'
)

# Move all contents into subdirectory of repo 2
(cd bugsnag-cocoa
  # TODO: something to make local copies of all remote branches?
  git checkout -b nested-directory
  mkdir nested-directory

  # Move all repo contents into nested-directory (except for nested-directory itself)
  find . -mindepth 1 -maxdepth 1 -not -name nested-directory -exec git mv {} nested-directory/ \;
  
  # Rename directory, add, and commit.
  mv nested-directory bugsnag-cocoa
  git add .
  git commit -m 'Move bugsnag-cocoa into subdirectory'
)

# Merge both repos
(cd repo-merge

  # Add local repos as remotes, --tags brings the tags, -f fetches the remotes.
  git remote add --tags -f AppAuth-iOS ../AppAuth-iOS
  git remote add --tags -f bugsnag-cocoa ../bugsnag-cocoa

  # Checkout branch
  git checkout -b standard-merge

  # Merge allowing unrelated histories. 
  git merge AppAuth-iOS/nested-directory --allow-unrelated-histories
  git merge bugsnag-cocoa/nested-directory --allow-unrelated-histories

  # Remove remotes just to prevent accidentally pushing to them
  git remote rm AppAuth-iOS
  git remote rm bugsnag-cocoa

  # Copy this script into the repo
  cp $SCRIPT_PATH .

  # Write some notes to README.md
  notes=("## Notes"
    ""
    " - A standard merge like this is quite simple and easy to follow."
    " - Git history is preserved, but since the files are renamed, you can only fully view individual file history it with a \`git log --follow <file path>\`, and can't see it on GitHub."
    " - Since the move commits touch every file, we lose the last real contributors of each file."
    " - Commit SHAs are preserved. So any comments or tools referencing them or reverts that depend on the specific commit SHAs can still work."
    ""
    "See other branches for different approaches.")
  
  for l in "${notes[@]}"; do
    echo -e $l >> README.md;
  done;

  git add .
  git commit -m 'Copy script into repo for reference; Add README'

  # TODO: Merge branches?
  # TODO: Push to remote outside of this. Might need to split it into multiple pushes depending on repo size.
)
