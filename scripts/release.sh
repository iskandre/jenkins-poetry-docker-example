#! /bin/sh
set -e

last_release_branch="$(git branch | grep 'release-' | sort --version-sort -r | head -1)"
last_release_number=${last_release_branch##*-}
new_release_branh_name="release-$((last_release_number+1))"

git checkout -b $new_release_branh_name
export NEW_RELEASE_BRANCH=$new_release_branh_name

