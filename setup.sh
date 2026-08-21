#!/usr/bin/env bash
CONFIG_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONO_HOME="${HOME}/code/purajit/mono"
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
PURPLE=$'\033[0;35m'
RESET=$'\033[0m'

printf "Beginning configuration setup\n"
printf -- "- Using %s%s%s as source of config truth\n" "${PURPLE}" "${CONFIG_HOME}" "${RESET}"
if [[ "$RECLONE" == "1" ]]; then
  printf -- "- %sWill overwrite existing repos when needed%s\n" "${RED}" "${RESET}"
else
  printf -- "- %sWill pull latest versions of relevant git repos%s\n" "${WHITE}" "${RESET}"
fi
printf "\n"

# helpers
function overwrite_with_symlink {
  # set -x
  if [[ -L "$2" && "$(readlink "$2")" = "$1" ]]; then
    # symlink to expected file already exists, no action needed
    printf "%s%s %s   %s\n" "${GREEN}" "${RESET}" "$2" "$1"
    return
  elif [[ -d "$2" ]]; then
    rm -rf "$2"
  fi
  ln -Fs "$1" "$2"
  printf "%s%s %s   %s\n" "${GREEN}" "${RESET}" "$2" "$1"
}

function clone_repo {
  repo="$1"
  org="${2:-purajit}"
  git_repo_base="${HOME}/code/$org"
  mkdir -p "$git_repo_base"
  git_repo_folder="${git_repo_base}/$(echo "$repo" | rev | cut -d/ -f1 | rev | cut -d. -f1)"
  if [[ "${RECLONE}" == "true" || ! -d "${git_repo_folder}" ]]; then
    rm -rf "${git_repo_folder}"
    GIT_TERMINAL_PROMPT=0 git clone --single-branch --recursive "${repo}" "${git_repo_folder}"
    printf "%s%s %s   %s\n" "${GREEN}" "${RESET}" "${repo}" "${git_repo_folder}"
  elif [[ -z "${DONT_PULL}" ]]; then
    GIT_TERMINAL_PROMPT=0 git -C "$git_repo_folder" pull
    GIT_TERMINAL_PROMPT=0 git -C "$git_repo_folder" submodule update --init --recursive
    printf "%s%s Pulled latest %s   %s\n" "${GREEN}" "${RESET}" "${repo}" "${git_repo_folder}"
  else
    printf "%s%s %s   %s\n" "${GREEN}" "${RESET}" "${repo}" "${git_repo_folder}"
  fi
}

# individual setup steps
function setup_init {
  mkdir -p "${HOME}/.config/"
  printf "%s%s ~/.config present\n" "${GREEN}" "${RESET}"
  clone_repo "https://github.com/purajit/mono.git"
}

function setup_brew {
  if command -v brew &> /dev/null; then
    printf "%s%s Homebrew already installed\n" "${GREEN}" "${RESET}"
  else
    printf "%s %s Installing Homebrew\n" "${YELLOW}" "${RESET}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew update
  brew bundle --file="${CONFIG_HOME}/Brewfile"
  printf "%s%s Finished install from Brewfile\n" "${GREEN}" "${RESET}"
  brew doctor
}

function setup_shell {
  # common shell configs
  overwrite_with_symlink "${CONFIG_HOME}/_aliases" "${HOME}/.aliases"
  touch "${CONFIG_HOME}/_zshlocal"
  printf "%s%s %s/_zshlocal ready\n" "${GREEN}" "${RESET}" "${CONFIG_HOME}"
  overwrite_with_symlink "${CONFIG_HOME}/_zshlocal" "${HOME}/.zshlocal"

  # LSCOLORS via vivid + trapd00r
  overwrite_with_symlink "${CONFIG_HOME}/_lscolors" "${HOME}/.lscolors"
  # TODO: use vivid instead https://github.com/trapd00r/LS_COLORS/issues/195
  # mkdir -p "${HOME}/.config/vivid/themes"
  # overwrite_with_symlink "${CONFIG_HOME}/vivid_trapd00r.yml" "${HOME}/.config/vivid/themes/trapd00r.yml"

  # shell tools
  clone_repo "https://github.com/purajit/venv_manager.git"
  overwrite_with_symlink "${CONFIG_HOME}/atuin-config.toml" "${HOME}/.config/atuin/config.toml"

  # zsh
  overwrite_with_symlink "${CONFIG_HOME}/_zshrc" "${HOME}/.zshrc"
  overwrite_with_symlink "${CONFIG_HOME}/_zprofile" "${HOME}/.zprofile"

  # tmux
  overwrite_with_symlink "${CONFIG_HOME}/_tmux.conf" "${HOME}/.tmux.conf"

  # tmux plugins
  mkdir -p "${HOME}/.tmux/plugins"
  overwrite_with_symlink "${MONO_HOME}/tmux-wifiorethernet" "${HOME}/.tmux/plugins/tmux-wifiorethernet"
  clone_repo "https://github.com/Morantron/tmux-fingers.git" "Morantron"
  overwrite_with_symlink "${HOME}/code/Morantron/tmux-fingers" "${HOME}/.tmux/plugins/tmux-fingers"
  clone_repo "https://github.com/tmux-plugins/tmux-cpu.git" "tmux-plugins"
  overwrite_with_symlink "${HOME}/code/tmux-plugins/tmux-cpu" "${HOME}/.tmux/plugins/tmux-cpu"
  clone_repo "https://github.com/tmux-plugins/tmux-battery.git" "tmux-plugins"
  overwrite_with_symlink "${HOME}/code/tmux-plugins/tmux-battery" "${HOME}/.tmux/plugins/tmux-battery"
  printf "%s%s Terraform plugins installed\n" "${GREEN}" "${RESET}"

  if [ -n "$TMUX" ]; then
    tmux source "${HOME}/.tmux.conf"
    printf "%s%s Active tmux session updated to latest configs\n" "${GREEN}" "${RESET}"
  fi

  # Alacritty
  overwrite_with_symlink "${CONFIG_HOME}/alacritty.toml" "${HOME}/.config/alacritty.toml"
  # Theming
  mkdir -p "$HOME/.config/alacritty"
  rm -rf "$HOME/.config/alacritty/active_theme.toml"
  overwrite_with_symlink "${CONFIG_HOME}/alacritty_dark.toml" "$HOME/.config/alacritty/dark.toml"
  overwrite_with_symlink "${CONFIG_HOME}/alacritty_light.toml" "$HOME/.config/alacritty/light.toml"
  # Replace icon
  rm /Applications/Alacritty.app/Contents/Resources/alacritty.icns
  cp "${CONFIG_HOME}/alacritty.icns" /Applications/Alacritty.app/Contents/Resources/alacritty.icns
  touch /Applications/Alacritty.app
  printf "%s%s Replaced Alacritty icon\n" "${GREEN}" "${RESET}"

  # Ghostty
  overwrite_with_symlink "${CONFIG_HOME}/ghostty" "${HOME}/.config/ghostty"
  printf "%s%s Configured Ghostty\n" "${GREEN}" "${RESET}"
}

function setup_automation {
  mkdir -p "${HOME}/.hammerspoon/Spoons"
  overwrite_with_symlink "${CONFIG_HOME}/hammerspoon_init.lua" "${HOME}/.hammerspoon/init.lua"
  for spoon in "${MONO_HOME}/Spoons/"*; do
    overwrite_with_symlink "$spoon" "${HOME}/.hammerspoon/Spoons/$(basename "$spoon")"
  done
}

function setup_emacs {
  rm -f "${HOME}/.emacs" "${HOME}/.emacs.d"
  overwrite_with_symlink "${CONFIG_HOME}/emacs" "${HOME}/.config/emacs"
  emacs --batch --init-directory "${HOME}/.config/emacs" \
    -l "${HOME}/.config/emacs/early-init.el" \
    -l "${HOME}/.config/emacs/init.el" \
    --eval '(pm/install-tree-sitter-grammars)' \
    --eval '(pm/smoke-test)' \
    --eval '(message "Emacs packages and tree-sitter grammars installed")'

  # https://github.com/ghostty-org/ghostty/discussions/5902
  emacs_launch_plist="$HOME/Library/LaunchAgents/homebrew.mxcl.emacs-plus@30.plist"
  /usr/libexec/PlistBuddy -c "Print :EnvironmentVariables:TERMINFO" "$emacs_launch_plist" > /dev/null 2>&1 \
    || /usr/libexec/PlistBuddy -c "Add :EnvironmentVariables:TERMINFO string /Applications/Ghostty.app/Contents/Resources/terminfo" "$emacs_launch_plist"
  printf "%s%s Configured TERMINFO for emacs launchagent\n" "${GREEN}" "${RESET}"

  printf "%s%s Installed and configured Emacs\n" "${GREEN}" "${RESET}"
}

function setup_git {
  overwrite_with_symlink "${CONFIG_HOME}/_gitconfig" "${HOME}/.gitconfig"
  overwrite_with_symlink "${CONFIG_HOME}/_gitignore_global" "${HOME}/.gitignore_global"
  overwrite_with_symlink "${CONFIG_HOME}/git" "${HOME}/.config/git"
}

function setup_defaults {
  # Apps
  defaults write org.p0deje.Maccy clipboardCheckInterval -float 2
  printf "%s%s Increased Maccy check interval to 2s\n" "${GREEN}" "${RESET}"

  # Appearance and text input
  defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"
  printf "%s%s Scroll bars will only appear while scrolling\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain AppleWindowTabbingMode -string "always"
  printf "%s%s Windows will always prefer opening documents in tabs\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  printf "%s%s Disabled automatic capitalization\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  printf "%s%s Disabled smart dash substitution\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false
  printf "%s%s Disabled inline predictive text\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  printf "%s%s Disabled inserting a period after a double-space\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  printf "%s%s Disabled smart quote substitution\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false
  printf "%s%s Disabled automatic spelling correction in native and web views\n" "${GREEN}" "${RESET}"

  # Keyboard and trackpad
  defaults -currentHost write NSGlobalDomain \
    "com.apple.keyboard.modifiermapping.0-0-0" -array \
    '{ HIDKeyboardModifierMappingSrc = 30064771129; HIDKeyboardModifierMappingDst = 30064771300; }'
  printf "%s%s Mapped Caps Lock to Right Control\n" "${GREEN}" "${RESET}"

  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 3
  for trackpad_domain in \
    com.apple.AppleMultitouchTrackpad \
    com.apple.driver.AppleBluetoothMultitouch.trackpad; do
    defaults write "${trackpad_domain}" Clicking -bool true
    defaults write "${trackpad_domain}" Dragging -bool true
    defaults write "${trackpad_domain}" DragLock -bool true
    defaults write "${trackpad_domain}" TrackpadTwoFingerDoubleTapGesture -int 0
  done
  printf "%s%s Enabled tap to click and drag lock for trackpads\n" "${GREEN}" "${RESET}"

  defaults -currentHost write NSGlobalDomain com.apple.trackpad.twoFingerDoubleTapGesture -int 0
  printf "%s%s Disabled the two-finger Smart Zoom gesture\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false
  defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -int 0
  defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool true
  printf "%s%s Disabled Force Click and haptic detents\n" "${GREEN}" "${RESET}"

  # Dock
  defaults write com.apple.dock autohide -bool true
  printf "%s%s Dock will hide automatically\n" "${GREEN}" "${RESET}"

  defaults write com.apple.dock magnification -bool true
  defaults write com.apple.dock tilesize -int 34
  defaults write com.apple.dock largesize -int 39
  printf "%s%s Adjusted Dock magnification\n" "${GREEN}" "${RESET}"

  defaults write com.apple.dock persistent-apps -array
  defaults write com.apple.dock persistent-others -array
  printf "%s%s Removed all Dock entries\n" "${GREEN}" "${RESET}"

  defaults write com.apple.dock show-recents -bool false
  printf "%s%s Dock will not show recently used apps\n" "${GREEN}" "${RESET}"

  defaults write com.apple.dock showDesktopGestureEnabled -bool false
  printf "%s%s Disabled the trackpad gesture for showing the desktop\n" "${GREEN}" "${RESET}"

  defaults write com.apple.dock wvous-bl-corner -int 13
  defaults write com.apple.dock wvous-bl-modifier -int 0
  printf "%s%s Bottom-left Hot Corner will lock the screen\n" "${GREEN}" "${RESET}"

  # Finder
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  printf "%s%s Finder will show all filename extensions\n" "${GREEN}" "${RESET}"

  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  printf "%s%s New Finder windows will use list view\n" "${GREEN}" "${RESET}"

  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  printf "%s%s New Finder windows will open the home folder\n" "${GREEN}" "${RESET}"

  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
  printf "%s%s Finder will show external and removable drives on the desktop\n" "${GREEN}" "${RESET}"

  defaults write com.apple.finder ShowRecentTags -bool false
  printf "%s%s Finder will hide recent tags in the sidebar\n" "${GREEN}" "${RESET}"

  # Desktop and windows
  defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
  defaults write com.apple.WindowManager HideDesktop -bool true
  printf "%s%s Desktop icons will be hidden\n" "${GREEN}" "${RESET}"

  defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
  printf "%s%s Tiled windows will not have margins between them\n" "${GREEN}" "${RESET}"

  # Screenshots
  mkdir -p "${HOME}/Documents/Screenshots"
  defaults write com.apple.screencapture location -string "${HOME}/Documents/Screenshots"
  printf "%s%s Screenshots will be stored in %s/Documents/Screenshots\n" "${GREEN}" "${RESET}" "${HOME}"

  # Apps bundled with macOS
  defaults write com.apple.TextEdit RichText -int 0
  printf "%s%s TextEdit will create plain-text documents by default\n" "${GREEN}" "${RESET}"

  defaults write com.apple.TextEdit CorrectSpellingAutomatically -bool false
  defaults write com.apple.TextEdit SmartCopyPaste -bool false
  defaults write com.apple.TextEdit SmartDashes -bool false
  defaults write com.apple.TextEdit SmartQuotes -bool false
  defaults write com.apple.TextEdit SmartSubstitutionsEnabledInRichTextOnly -bool false
  defaults write com.apple.TextEdit TextReplacement -bool false
  printf "%s%s Disabled TextEdit spelling correction and smart substitutions\n" "${GREEN}" "${RESET}"

  defaults write com.apple.ActivityMonitor ShowCategory -int 100
  printf "%s%s Activity Monitor will show all processes\n" "${GREEN}" "${RESET}"

  # at the end
  killall SystemUIServer 2> /dev/null || true
  killall Finder 2> /dev/null || true
  killall Dock 2> /dev/null || true
  printf "%s%s Restarted UI elements so certain changes go into effect\n" "${GREEN}" "${RESET}"
}

function setup_misc {
  if brew list rust &> /dev/null; then
    brew uninstall rust
    printf "%s%s Uninstalled Brew-maintained rust toolchain (in favor of rustup)\n" "${GREEN}" "${RESET}"
  fi

  if command -v cargo &> /dev/null; then
    printf "%s%s Rust 🦀 toolchain already installed\n" "${GREEN}" "${RESET}"
  else
    printf "%s %s Running rustup\n" "${YELLOW}" "${RESET}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  fi

  overwrite_with_symlink "${CONFIG_HOME}/_editorconfig" "${HOME}/.editorconfig"
  overwrite_with_symlink "${CONFIG_HOME}/k9s" "${HOME}/.config/k9s"
  mkdir -p "${HOME}/.ipython/profile_default/"
  overwrite_with_symlink "${CONFIG_HOME}/ipython_config.py" "${HOME}/.ipython/profile_default/ipython_config.py"
  mkdir -p "${HOME}/.config/gh-dash"
  overwrite_with_symlink "${CONFIG_HOME}/gh-dash-config.yml" "${HOME}/.config/gh-dash/config.yml"
  mkdir -p "${HOME}/.ssh"
  overwrite_with_symlink "${CONFIG_HOME}/ssh_config" "${HOME}/.ssh/config"
  overwrite_with_symlink "${CONFIG_HOME}/_terraformrc" "${HOME}/.terraformrc"
  mkdir -p "${HOME}/.terraform.d/plugin-cache"
  printf "%s%s Created Terraform global plugin cache\n" "${GREEN}" "${RESET}"
  overwrite_with_symlink "${CONFIG_HOME}/iina.conf" "${HOME}/Library/Application Support/com.colliderli.iina/input_conf/custom.conf"
}

ALL_MODULES=(
  "init"
  # first, a package manager
  "brew"
  # then, the shell, terminal, editor, basic automation
  "shell"
  "automation"
  "emacs"
  # the rest
  "git"
  "defaults"
  "misc"
)

if [[ "$#" == 1 && "$1" == "all" ]]; then
  modules=("${ALL_MODULES[@]}")
else
  modules=("init" "$@")
fi
for module in "${modules[@]}"; do
  printf "╭─ "
  if [ "$module" = "init" ]; then
    printf "%s... init ...%s\n" "${YELLOW}" "${RESET}"
  elif [ "$module" = "brew" ]; then
    printf "%s  Brew, bundles%s\n" "${YELLOW}" "${RESET}"
  elif [ "$module" = "shell" ]; then
    printf "%s zsh, tmux, terminals%s\n" "${YELLOW}" "${RESET}"
  elif [ "$module" = "automation" ]; then
    printf "%s󱚣  Automation tools%s\n" "${YELLOW}" "${RESET}"
  elif [ "$module" = "emacs" ]; then
    printf "%s  Emacs%s\n" "${YELLOW}" "${RESET}"
  elif [ "$module" = "git" ]; then
    printf "%s  Git%s\n" "${YELLOW}" "${RESET}"
  elif [ "$module" = "defaults" ]; then
    printf "%s defaults/plists%s\n" "${YELLOW}" "${RESET}"
  elif [ "$module" = "misc" ]; then
    printf "%s󱁢 m 󰅟  i    s  󰹑    c    🦀%s\n" "${YELLOW}" "${RESET}"
  else
    printf "\n╰─ %sUnknown module  %s  :c%s\n" "${RED}" "${module}" "${RESET}"
    continue
  fi

  exec 3>&1 4>&2
  exec > >(sed -u 's/^/│ /')
  exec 2> >(sed -u 's/^/│ /' >&2)

  if [ "$module" = "init" ]; then
    setup_init
  elif [ "$module" = "brew" ]; then
    setup_brew
  elif [ "$module" = "shell" ]; then
    setup_shell
  elif [ "$module" = "automation" ]; then
    setup_automation
  elif [ "$module" = "emacs" ]; then
    setup_emacs
  elif [ "$module" = "git" ]; then
    setup_git
  elif [ "$module" = "defaults" ]; then
    setup_defaults
  elif [ "$module" = "misc" ]; then
    setup_misc
  fi

  exec 1>&3 2>&4
  exec 3>&- 4>&-

  printf "╰─ %sFinished!%s\n\n" "${GREEN}" "${RESET}"
done

printf "All done!"
