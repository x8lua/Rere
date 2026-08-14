#!/usr/bin/env sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
git -C "$repo_dir" show upstream/main:README.md > "$repo_dir/artifacts/ROLLBACK_COPY.md"
cmp -s "$repo_dir/artifacts/BASELINE_FILE.md" "$repo_dir/artifacts/ROLLBACK_COPY.md"
printf '%s\n' 'rollback restored ROLLBACK_COPY.md from the Iris upstream baseline'
