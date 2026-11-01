#!/bin/sh
# Run as root (pkexec). Installs the session + pacman hook, removes the old gaps-only hook.
set -e
D=$(dirname "$(readlink -f "$0")")
install -m755 "$D/start-cosmic-patched"   /usr/local/bin/start-cosmic-patched
install -m644 "$D/cosmic-patched.desktop" /usr/share/wayland-sessions/cosmic-patched.desktop
install -m644 "$D/cosmic-patches.hook"    /etc/pacman.d/hooks/cosmic-patches.hook
rm -f /etc/pacman.d/hooks/cosmic-comp-gaps.hook
