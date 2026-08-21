# Emacs configuration

This is a native Emacs 30 configuration. It uses the standard Emacs keys and
keeps mutable package data under `~/.local/share/emacs`, caches under
`~/.cache/emacs`, and state under `~/.local/state/emacs`.

## Install

Run `./setup.sh emacs` from the repository root. The first run downloads the
package manager and the exact package revisions in `versions.el`.

## Upgrade packages safely

Run `emacs/bin/upgrade`, or type `C-c p u` inside Emacs. The upgrade rebuilds
every package and starts a fresh batch Emacs that loads the important deferred
packages. If either step fails, it restores the previous lockfile, checkouts,
and builds. Commit `versions.el` after a successful upgrade.

The configured tree-sitter grammars are installed by `setup.sh` and stored
outside the config repository. Run `M-x pm/install-tree-sitter-grammars` to
install newly added grammars without rerunning setup. Eglot starts automatically
for Python (using basedpyright) and Go. Format-on-save uses Apheleia; Python uses
Ruff and shell files use shfmt.
