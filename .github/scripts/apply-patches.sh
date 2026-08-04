#!/usr/bin/env bash
set -euo pipefail

# Resolve the sync branch root from this script's own location, so the script
# works no matter what the caller's working directory is.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sync_root="$(cd "$SCRIPT_DIR/../.." && pwd)"

patches_dir="$sync_root/patches"

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

if [ ! -d "$patches_dir" ]; then
  echo "Patches folder not found ($patches_dir), skipping patches"
  exit 0
fi

# -print0 + sort -z + mapfile -d '' keeps this safe for any filenames and
# sorts by name, so 00_/01_/02_/... controls the application order. Only
# .patch/.diff/.sh files are picked up; everything else (e.g. README.md)
# is ignored.
mapfile -d '' patches < <(
  find "$patches_dir" -maxdepth 1 -type f \
    \( -name '*.patch' -o -name '*.diff' -o -name '*.sh' \) -print0 | sort -z
)

if [ ${#patches[@]} -eq 0 ]; then
  echo "No patch files found in $patches_dir, skipping patches"
  exit 0
fi

echo "Files found: ${#patches[@]}"

for patch in "${patches[@]}"; do
  name="$(basename "$patch")"

  case "$patch" in
    *.patch | *.diff)
      handler="git apply"
      ;;
    *.sh)
      handler="bash"
      ;;
  esac

  echo "::group::Applying $name"
  $handler "$patch" || { echo "Failed to apply $name"; exit 1; }

  git add -A
  if git diff --cached --quiet; then
    echo "$name made no changes, skipping commit"
  else
    git commit -m "$name"
  fi
  echo "::endgroup::"
done
