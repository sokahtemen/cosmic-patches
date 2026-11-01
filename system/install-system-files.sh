#!/bin/sh
# Run as root (pkexec). Installs the login session and the pacman hook, filled in
# for this checkout and the user who owns it. Re-run it after moving the checkout.
set -e
D=$(dirname "$(readlink -f "$0")")
ROOT=$(dirname "$D")
sed "s|@ROOT@|$ROOT|" "$D/start-cosmic-patched" > /usr/local/bin/start-cosmic-patched
chmod 755 /usr/local/bin/start-cosmic-patched
install -m644 "$D/cosmic-patched.desktop" /usr/share/wayland-sessions/cosmic-patched.desktop
sed "s/@USER@/$(stat -c %U "$ROOT")/" "$D/cosmic-patches.hook" > /etc/pacman.d/hooks/cosmic-patches.hook
chmod 644 /etc/pacman.d/hooks/cosmic-patches.hook
