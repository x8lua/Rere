#!/usr/bin/env sh
set -eu

artifact_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
target=${1:?usage: ROLLBACK.sh TARGET_FILE}
cp "$artifact_dir/BASELINE_FILE.lua" "$target"
printf '%s\n' "rollback restored $target from BASELINE_FILE.lua"
