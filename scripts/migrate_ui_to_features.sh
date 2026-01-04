#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"
PKG_NAME="pamoja_twalima"

echo "Repo root: $REPO_ROOT"
echo "Package name: $PKG_NAME"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree not clean. Commit or stash changes before running."
  git status --porcelain
  exit 1
fi

FEATURES=(auth business core farm_mgmt home inventory knowledge marketplace onboarding profile weather)
DRY_RUN=${DRY_RUN:-0}

mkdir_p() {
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "mkdir -p $1"
  else
    mkdir -p "$1"
  fi
}

git_mv() {
  if [[ ! -e "$1" ]]; then
    echo "skip missing: $1"
    return
  fi
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "git mv $1 $2"
  else
    git mv "$1" "$2"
  fi
}

for f in "${FEATURES[@]}"; do
  SRC_DIR="lib/ui/$f"
  if [[ ! -d "$SRC_DIR" ]]; then
    echo "Skipping missing feature: $f"
    continue
  fi

  TARGET_BASE="lib/$f/presentation"
  echo "--- Processing feature: $f ---"
  echo "Source: $SRC_DIR"
  echo "Target: $TARGET_BASE"

  mkdir_p "$TARGET_BASE"

  shopt -s nullglob
  for file in "$SRC_DIR"/*.dart; do
    base="$(basename "$file")"
    if [[ "$base" == "$f.dart" || "$base" == "index.dart" ]]; then
      echo "Skipping possible shim $file"
      continue
    fi
    dest="$TARGET_BASE/$base"
    echo "Moving $file -> $dest"
    git_mv "$file" "$dest"
  done
  shopt -u nullglob

  shopt -s nullglob
  for sub in "$SRC_DIR"/*/; do
    subbase="$(basename "$sub")"
    echo "Moving subdir $sub -> $TARGET_BASE/$subbase/"
    mkdir_p "$TARGET_BASE/$subbase"
    shopt -s nullglob
    for sf in "$sub"*.dart; do
      dest="$TARGET_BASE/$subbase/$(basename "$sf")"
      echo "  - $sf -> $dest"
      git_mv "$sf" "$dest"
    done
    shopt -u nullglob
    if [[ "$DRY_RUN" == "0" ]]; then
      rmdir --ignore-fail-on-non-empty "$sub" || true
    else
      echo "Would rmdir $sub (dry run)"
    fi
  done
  shopt -u nullglob

  PRESENTATION_BARREL="$TARGET_BASE/presentation.dart"
  echo "Creating barrel $PRESENTATION_BARREL"
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "Would create barrel with exports for $TARGET_BASE"
  else
    {
      echo "// Barrel for $f presentation"
      for d in "$TARGET_BASE"/*.dart; do
        name="$(basename "$d")"
        echo "export '$name';"
      done
      for sub in "$TARGET_BASE"/*/; do
        subname="$(basename "$sub")"
        for sd in "$sub"*.dart; do
          sname="$(basename "$sd")"
          echo "export '$subname/$sname';"
        done
      done
    } > "$PRESENTATION_BARREL"
    git add "$PRESENTATION_BARREL" || true
    git commit -m "chore(presentation): add $f presentation barrel" --no-verify || true
  fi

  SHIM_FILE="lib/ui/$f.dart"
  echo "Creating/updating shim $SHIM_FILE -> export package:$PKG_NAME/$f/presentation/presentation.dart"
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "Would write shim $SHIM_FILE"
  else
    echo "export 'package:$PKG_NAME/$f/presentation/presentation.dart';" > "$SHIM_FILE"
    git add "$SHIM_FILE" || true
    git commit -m "chore(shim): re-export $f presentation barrel" --no-verify || true
  fi

done

if [[ "$DRY_RUN" == "1" ]]; then
  echo "DRY_RUN: skipping format/analyze"
  exit 0
fi

echo "Running flutter format ."
flutter format . || true

echo "Running dart analyze"
dart analyze || true

echo "Migration script finished. Inspect git status and run app to validate." 
