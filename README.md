# cosmic-patches

Locally patched COSMIC components. Everything not patched here stays the stock Arch package.

- Login session **"COSMIC (patched)"** → uses patched binaries (only those built for the installed version).
- Login session **"COSMIC"** → completely stock. Use it as fallback if a patched build misbehaves.

## Add a component
    git clone https://github.com/pop-os/<repo> ~/cosmic-patches/<repo>/src
    # make changes in src, then:
    mkdir ~/cosmic-patches/<repo>/patches
    git -C ~/cosmic-patches/<repo>/src diff > ~/cosmic-patches/<repo>/patches/10-<name>.patch
    # optional: component.conf (PKG / BINS / TAG) if package/binary name differs from dir name
    ~/cosmic-patches/rebuild.sh <repo>

## Automation
- `cosmic-patches-rebuild.service` (user, at login, idle priority) runs `rebuild.sh`.
- `/etc/pacman.d/hooks/cosmic-patches.hook` starts it after any `cosmic-*` upgrade.
- System files live in `system/`; reinstall with `pkexec ~/cosmic-patches/system/install-system-files.sh`.

## AI-generated

This project is vibecoded: all of the code, patches and docs were written by
[Claude Code](https://claude.com/claude-code) using **Claude Opus 5.5**
(`claude-opus-5-5`) at **medium effort**. A human gave the directions and did
the testing, but did not review the code line by line.
