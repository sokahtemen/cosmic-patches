# cosmic-patches

Locally patched COSMIC components. Everything not patched here stays the stock Arch package.

- Login session **"COSMIC (patched)"** → uses patched binaries (only those built for the installed version).
- Login session **"COSMIC"** → completely stock. Use it as fallback if a patched build misbehaves.

## Add a component
    git clone https://github.com/pop-os/<repo> ~/git/cosmic-patches/<repo>/src
    # make changes in src, then:
    mkdir ~/git/cosmic-patches/<repo>/patches
    git -C ~/git/cosmic-patches/<repo>/src diff > ~/git/cosmic-patches/<repo>/patches/10-<name>.patch
    ~/git/cosmic-patches/rebuild.sh <repo>

If the pacman package or the binaries are named differently from the folder, add
`<repo>/component.conf` with `PKG=<package>` and/or `BINS="<binary> ..."`.

## Install
    pkexec ~/git/cosmic-patches/system/install-system-files.sh
    systemctl --user enable ~/git/cosmic-patches/system/cosmic-patches-rebuild.service

- The first line installs the login session and `/etc/pacman.d/hooks/cosmic-patches.hook`,
  which starts the rebuild after any `cosmic-*` upgrade.
- The second links the user service (at login, idle priority) that runs `rebuild.sh`.
  It is a link, so edits to the file in `system/` apply after `systemctl --user daemon-reload`.
- After moving the checkout, update `ExecStart` in the service and run both lines again.

## AI-generated

This project is vibecoded: all of the code, patches and docs were written by
[Claude Code](https://claude.com/claude-code) using **Claude Opus 5.5**
(`claude-opus-5-5`) at **medium effort**, with a cleanup pass at **max effort**. A human gave the directions and did
the testing, but did not review the code line by line.

## License

[GPL-3.0](LICENSE), the same as cosmic-comp, since the patches modify its code.
