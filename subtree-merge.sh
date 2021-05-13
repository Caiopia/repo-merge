#!/bin/bash
set -eux

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

# Clone the two repos to merge 
git clone https://github.com/Caiopia/AppAuth-iOS.git
git clone https://github.com/Caiopia/bugsnag-cocoa.git

# Clone/create the repo to merge into. This one has a main branch with a single empty commit.
git clone https://github.com/Caiopia/repo-merge.git 

# Merge both repos
(cd repo-merge

  # Checkout branch
  git checkout -b subtree-merge

  # Add the two local repos as subtrees and push to it. `--prefix` defines the directory we want it to live in.
  git subtree add --prefix=AppAuth-iOS ../AppAuth-iOS master
  git subtree add --prefix=bugsnag-cocoa ../bugsnag-cocoa master

  # Copy this script into the repo
  cp $SCRIPT_PATH .

  # Write some notes to README.md
  notes=("## Notes"
    ""
    " - Using \`git subtree\` like this is really simple."
    " - Git history is sort of preserved, but only in the root directory. Reverts or blames won't work well because of this."
    " - We aren't able to view history of individual files using \`git log --follow <file path>\` nor in GitHub."
    " - Does have the ability to pull from each repo to make it easy to iterate on changes."
    ""
    "See other branches for different approaches.")
  
  for l in "${notes[@]}"; do
    echo -e $l >> README.md;
  done;
  
  git add .
  git commit -m 'Copy script into repo for reference; Add README'

  # TODO: Push to remote outside of this. Might need to split it into multiple pushes depending on repo size.
)
