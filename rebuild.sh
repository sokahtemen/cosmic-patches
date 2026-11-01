#!/bin/sh
# Rebuild every patched COSMIC component in ~/cosmic-patches/<component>/ whose build
# doesn't match the installed pacman package. Components already up to date are skipped.
#
# Component layout:
#   <component>/src/            git clone of the upstream repo
#   <component>/patches/*.patch applied in name order on top of the release tag
#   <component>/component.conf  optional: PKG, BINS, TAG (see cosmic-comp/component.conf)
#   <component>/bin/, version   build output (written by this script)
#
# Usage: rebuild.sh [component ...]   (default: all components)
set -u

ROOT="$HOME/cosmic-patches"
status=0

notify() { notify-send ${3:+-u "$3"} "COSMIC patches" "$1: $2" 2>/dev/null || true; }

build_component() (
    set -eu
    comp="$1"
    dir="$ROOT/$comp"
    PKG="$comp"; BINS="$comp"; TAG='epoch-$upstream'
    [ -f "$dir/component.conf" ] && . "$dir/component.conf"

    installed=$(pacman -Q "$PKG" 2>/dev/null | cut -d' ' -f2) || true
    [ -n "$installed" ] || { echo "$comp: package $PKG not installed, skipping"; exit 0; }
    upstream=$(echo "$installed" | sed 's/^[0-9]*://; s/-[^-]*$//')   # 1:1.10.0-1.1 -> 1.10.0
    tag=$(eval "echo \"$TAG\"")

    if [ "$(cat "$dir/version" 2>/dev/null || true)" = "$installed" ]; then
        echo "$comp: already built for $installed"
        exit 0
    fi

    fail() { echo "$comp: ERROR: $1" >&2; notify "$comp" "rebuild for $installed failed: $1 (stock version will be used)" critical; exit 1; }

    notify "$comp" "rebuilding for $installed…"
    cd "$dir/src"
    git fetch --quiet --tags origin || fail "git fetch failed"
    git rev-parse -q --verify "refs/tags/$tag" >/dev/null || fail "no upstream tag $tag"
    git reset --quiet --hard
    git checkout --quiet "$tag"
    for p in "$dir"/patches/*.patch; do
        [ -e "$p" ] || continue
        git apply "$p" || fail "$(basename "$p") no longer applies to $tag"
    done

    cargo build --release --locked || fail "cargo build failed"

    mkdir -p "$dir/bin"
    for b in $BINS; do
        install -m755 "target/release/$b" "$dir/bin/$b.new"
        mv -f "$dir/bin/$b.new" "$dir/bin/$b"
    done
    echo "$installed" > "$dir/version"
    notify "$comp" "rebuilt for $installed. Log out and back in to use it."
)

if [ $# -eq 0 ]; then
    set --
    for d in "$ROOT"/*/patches; do
        [ -d "$d" ] && set -- "$@" "$(basename "$(dirname "$d")")"
    done
fi

for comp in "$@"; do
    build_component "$comp" || status=1
done
exit $status
