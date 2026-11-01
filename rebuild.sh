#!/bin/sh
# Rebuild every patched COSMIC component in this folder whose build doesn't match
# the installed pacman package. Components already up to date are skipped.
#
# Component layout:
#   <component>/src/            git clone of the upstream repo
#   <component>/patches/*.patch applied in name order on top of the release tag
#   <component>/component.conf  optional: PKG (pacman package) and BINS (binaries
#                               to install); both default to the folder name
#   <component>/bin/, version   build output, written by this script; version holds
#                               the `pacman -Q` line the build was made for
#
# Usage: rebuild.sh [component ...]   (default: all components)
set -u

ROOT=$(dirname "$(readlink -f "$0")")
status=0

notify() { notify-send ${3:+-u "$3"} "COSMIC patches" "$1: $2" 2>/dev/null || true; }

build_component() (
    set -eu
    comp="$1"
    dir="$ROOT/$comp"
    PKG="$comp"; BINS="$comp"
    [ -f "$dir/component.conf" ] && . "$dir/component.conf"

    installed=$(pacman -Q "$PKG" 2>/dev/null) || { echo "$comp: package $PKG not installed, skipping"; exit 0; }
    if [ "$(cat "$dir/version" 2>/dev/null || true)" = "$installed" ]; then
        echo "$comp: already built for $installed"
        exit 0
    fi
    ver=${installed#* }                                            # 1:1.10.0-1.1
    tag=epoch-$(echo "$ver" | sed 's/^[0-9]*://; s/-[^-]*$//')     # epoch-1.10.0

    fail() { echo "$comp: ERROR: $1" >&2; notify "$comp" "rebuild for $ver failed: $1 (stock version will be used)" critical; exit 1; }

    notify "$comp" "rebuilding for $ver…"
    cd "$dir/src"
    # Offline is fine as long as the tag was fetched before.
    git fetch --quiet --tags origin || echo "$comp: git fetch failed, using local tags" >&2
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
    notify "$comp" "rebuilt for $ver. Log out and back in to use it."
)

if [ $# -eq 0 ]; then
    for d in "$ROOT"/*/patches; do
        [ -d "$d" ] && set -- "$@" "$(basename "$(dirname "$d")")"
    done
fi

for comp in "$@"; do
    build_component "$comp" || status=1
done
exit $status
