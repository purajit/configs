# taps
tap "d12frosted/emacs-plus"
tap "derailed/k9s"

# terminal/tmux/shell experience
brew "atuin"
brew "coreutils"
cask "font-mononoki-nerd-font"
cask "ghostty@tip"
brew "reattach-to-user-namespace"
brew "tmux"
brew "crystal"  # to build tmux-fingers from source
brew "vivid"
brew "zsh-syntax-highlighting"

# essentials
brew "emacs-plus@30"
brew "fd"
cask "librewolf", args: { no_quarantine: true }
brew "fzf"
brew "gnupg"
cask "hammerspoon"
cask "logi-options+"
cask "maccy"
brew "ripgrep"
brew "jq"
brew "yq"

# second-level essentials
brew "colima"
brew "derailed/k9s/k9s"
brew "direnv"
brew "docker"
brew "gh"
cask "google-drive"
brew "helm"
brew "kubectl"
brew "terraformer"

# linters and code management
brew "aspell"
brew "editorconfig"
brew "go"
brew "ruff"
brew "shellcheck"
brew "shfmt"
brew "uv"

# random tools
brew "ffmpeg"
brew "graphviz"
brew "imagemagick"
brew "pandoc"
brew "pdsh"
brew "presenterm"

# personal tools
cask "android-platform-tools" if ENV['HOMEBREW_MACHINE'] != "work"
cask "cryptomator" if ENV['HOMEBREW_MACHINE'] != "work"
cask "discord" if ENV['HOMEBREW_MACHINE'] != "work"
cask "keepassxc" if ENV['HOMEBREW_MACHINE'] != "work"
cask "mullvad-vpn@beta" if ENV['HOMEBREW_MACHINE'] != "work"
cask "signal" if ENV['HOMEBREW_MACHINE'] != "work"
cask "steam" if ENV['HOMEBREW_MACHINE'] != "work"
cask "wireshark" if ENV['HOMEBREW_MACHINE'] != "work"
# for cryptomator
tap "macos-fuse-t/cask" if ENV['HOMEBREW_MACHINE'] != "work"
cask "fuse-t" if ENV['HOMEBREW_MACHINE'] != "work"

# mac app store installs
brew "mas" if ENV['HOMEBREW_MACHINE'] != "work"
mas "Parcel", id: 375589283 if ENV['HOMEBREW_MACHINE'] != "work"

# formulae used in the past that are nice to track
# cask "ableton-live-suite"  # only one install :c
# cask "alacritty", args: {"no-quarantine": true}  # switched to ghostty
# cask "emacs"  # Emacs For MacOS X does not work with Doomemacs
# cask "figma"
# cask "jiggler"
# cask "mactex"
# cask "telegram"
# cask "tomatobar"
