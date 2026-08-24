#!/usr/bin/env bash
set -u

CONFIG_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONO_HOME="${HOME}/code/purajit/mono"
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
PURPLE=$'\033[0;35m'
WHITE=$'\033[0;37m'
RESET=$'\033[0m'

: ${RECLONE:=}
: ${DONT_PULL:=}

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

function set_symbolic_hotkey {
  local symbolic_hotkeys_plist="$1"
  local shortcut_id="$2"
  local enabled="$3"
  local description="$4"
  shift 4

  local plist_key=":AppleSymbolicHotKeys:${shortcut_id}"
  /usr/libexec/PlistBuddy -c "Add ${plist_key} dict" "${symbolic_hotkeys_plist}"
  /usr/libexec/PlistBuddy -c "Add ${plist_key}:enabled bool ${enabled}" "${symbolic_hotkeys_plist}"

  if [[ "$#" -eq 3 ]]; then
    local character_code="$1"
    local virtual_key_code="$2"
    local modifiers="$3"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value dict" "${symbolic_hotkeys_plist}"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value:parameters array" "${symbolic_hotkeys_plist}"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value:parameters:0 integer ${character_code}" "${symbolic_hotkeys_plist}"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value:parameters:1 integer ${virtual_key_code}" "${symbolic_hotkeys_plist}"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value:parameters:2 integer ${modifiers}" "${symbolic_hotkeys_plist}"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value:type string standard" "${symbolic_hotkeys_plist}"
  elif [[ "$#" -ne 0 ]]; then
    printf "Invalid symbolic hotkey definition for ID %s\n" "${shortcut_id}" >&2
    return 1
  fi

  if [[ "$enabled" == "true" ]]; then
    printf "%s%s Set shortcut for \"$description\" (${shortcut_id})\n" "${GREEN}" "${RESET}"
  else
    printf "%s%s Disabled shortcut for \"$description\" (${shortcut_id})\n" "${GREEN}" "${RESET}"
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
  mkdir -p "${HOME}/.config/mise"
  overwrite_with_symlink "${CONFIG_HOME}/mise-config.toml" "${HOME}/.config/mise/config.toml"
  overwrite_with_symlink "${CONFIG_HOME}/k9s" "${HOME}/.config/k9s"
  overwrite_with_symlink "${CONFIG_HOME}/k9s" "${HOME}/Library/Application Support/k9s"

  # zsh
  overwrite_with_symlink "${CONFIG_HOME}/_zshrc" "${HOME}/.zshrc"
  overwrite_with_symlink "${CONFIG_HOME}/_zprofile" "${HOME}/.zprofile"

  # tmux and screen
  overwrite_with_symlink "${CONFIG_HOME}/_tmux.conf" "${HOME}/.tmux.conf"
  overwrite_with_symlink "${CONFIG_HOME}/screenrc" "${HOME}/.screenrc"

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
  defaults write org.p0deje.Maccy KeyboardShortcuts_delete -string \
    '{"carbonKeyCode":51,"carbonModifiers":2048}'
  defaults write org.p0deje.Maccy KeyboardShortcuts_pin -int 0
  defaults write org.p0deje.Maccy KeyboardShortcuts_popup -string \
    '{"carbonModifiers":768,"carbonKeyCode":9}'
  defaults write org.p0deje.Maccy KeyboardShortcuts_togglePreview -int 0
  defaults write org.p0deje.Maccy ignoredApps -array \
    "com.apple.keychainaccess"
  defaults write org.p0deje.Maccy ignoredPasteboardTypes -array \
    "net.antelle.keeweb" \
    "de.petermaurer.TransientPasteboardType" \
    "com.typeit4me.clipping" \
    "Pasteboard generator type" \
    "com.agilebits.onepassword"
  defaults write org.p0deje.Maccy popupPosition -string "cursor"
  defaults write org.p0deje.Maccy previewWidth -int 400
  defaults write org.p0deje.Maccy searchVisibility -string "always"
  defaults write org.p0deje.Maccy showFooter -bool false
  defaults write org.p0deje.Maccy showSearch -bool true
  defaults write org.p0deje.Maccy showTitle -bool false
  defaults write org.p0deje.Maccy SUEnableAutomaticChecks -bool false
  printf "%s%s Configured Maccy\n" "${GREEN}" "${RESET}"

  defaults write org.hammerspoon.Hammerspoon HSConsoleDarkModeKey -bool true
  defaults write org.hammerspoon.Hammerspoon MJKeepConsoleOnTopKey -bool true
  defaults write org.hammerspoon.Hammerspoon SUAutomaticallyUpdate -bool false
  defaults write org.hammerspoon.Hammerspoon SUEnableAutomaticChecks -bool false
  defaults write org.hammerspoon.Hammerspoon SUSendProfileInfo -bool false
  printf "%s%s Configured Hammerspoon\n" "${GREEN}" "${RESET}"

  defaults write com.colliderli.iina PluginEnabled.io.iina.opensub -bool true
  defaults write com.colliderli.iina PluginEnabled.io.iina.user-script -bool true
  defaults write com.colliderli.iina PluginEnabled.io.iina.ytdl -bool true
  printf "%s%s Configured IINA\n" "${GREEN}" "${RESET}"

  defaults write app.cyan.markedit NSAllowContinuousSpellChecking -bool true
  defaults write app.cyan.markedit WebAutomaticLinkDetectionEnabled -bool true
  defaults write app.cyan.markedit WebAutomaticSpellingCorrectionEnabled -bool true
  defaults write app.cyan.markedit WebAutomaticTextReplacementEnabled -bool true
  defaults write app.cyan.markedit WebContinuousSpellCheckingEnabled -bool true
  defaults write app.cyan.markedit WebGrammarCheckingEnabled -bool true
  defaults write app.cyan.markedit editor.overwrite-text-checker -bool true
  printf "%s%s Configured MarkEdit\n" "${GREEN}" "${RESET}"

  # Appearance and text input
  defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"
  printf "%s%s Scroll bars will only appear while scrolling\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain AppleWindowTabbingMode -string "always"
  printf "%s%s Windows will always prefer opening documents in tabs\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false
  printf "%s%s Double-clicking a title bar will not minimize its window\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
  printf "%s%s Enabled full keyboard access for controls in windows and dialogs\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
  printf "%s%s Enabled swipe navigation\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool true
  printf "%s%s Switch spaces when activating an app\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain NSGlassDiffusionSetting -bool false
  printf "%s%s Liquid Glass will use the clear appearance\n" "${GREEN}" "${RESET}"

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

  defaults delete NSGlobalDomain NSUserDictionaryReplacementItems 2> /dev/null || true
  printf "%s%s Disabled custom system text replacements\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false
  printf "%s%s Disabled automatic spelling correction in native and web views\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain NSCloseAlwaysConfirmsChanges -bool true
  printf "%s%s Closing a document with unsaved changes will require confirmation\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain NSNavPanelFileLastListModeForOpenModeKey -int 2
  defaults write NSGlobalDomain NSNavPanelFileListModeForOpenMode2 -int 2
  defaults write NSGlobalDomain NavPanelFileListModeForOpenMode -int 2
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  printf "%s%s Open and save panels will use list view, with save panels expanded\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  printf "%s%s New documents will default to local storage instead of iCloud\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain com.apple.sound.beep.flash -bool false
  printf "%s%s Disabled the screen flash for alert sounds\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain com.apple.springing.delay -float 0.5
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true
  printf "%s%s Enabled spring-loaded folders\n" "${GREEN}" "${RESET}"

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
    defaults write "${trackpad_domain}" TrackpadCornerSecondaryClick -int 0
    defaults write "${trackpad_domain}" TrackpadFiveFingerPinchGesture -int 0
    defaults write "${trackpad_domain}" TrackpadFourFingerHorizSwipeGesture -int 2
    defaults write "${trackpad_domain}" TrackpadFourFingerPinchGesture -int 0
    defaults write "${trackpad_domain}" TrackpadFourFingerVertSwipeGesture -int 2
    defaults write "${trackpad_domain}" TrackpadHandResting -bool true
    defaults write "${trackpad_domain}" TrackpadHorizScroll -int 1
    defaults write "${trackpad_domain}" TrackpadMomentumScroll -bool true
    defaults write "${trackpad_domain}" TrackpadPinch -int 1
    defaults write "${trackpad_domain}" TrackpadRightClick -bool true
    defaults write "${trackpad_domain}" TrackpadRotate -int 1
    defaults write "${trackpad_domain}" TrackpadScroll -bool true
    defaults write "${trackpad_domain}" TrackpadThreeFingerDrag -bool false
    defaults write "${trackpad_domain}" TrackpadThreeFingerHorizSwipeGesture -int 2
    defaults write "${trackpad_domain}" TrackpadThreeFingerTapGesture -int 0
    defaults write "${trackpad_domain}" TrackpadThreeFingerVertSwipeGesture -int 2
    defaults write "${trackpad_domain}" TrackpadTwoFingerDoubleTapGesture -int 0
    defaults write "${trackpad_domain}" TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3
    defaults write "${trackpad_domain}" USBMouseStopsTrackpad -int 0
  done
  printf "%s%s Enabled tap to click and drag lock for trackpads\n" "${GREEN}" "${RESET}"
  printf "%s%s Configured trackpad scrolling, swiping, pinching\n" "${GREEN}" "${RESET}"

  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.fiveFingerPinchSwipeGesture -int 0
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerHorizSwipeGesture -int 2
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerPinchSwipeGesture -int 0
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerVertSwipeGesture -int 2
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.momentumScroll -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.pinchGesture -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.rotateGesture -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.scrollBehavior -int 2
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerDragGesture -int 0
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 2
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerTapGesture -int 0
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerVertSwipeGesture -int 2
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.twoFingerFromRightEdgeSwipeGesture -int 3

  defaults -currentHost write NSGlobalDomain com.apple.trackpad.twoFingerDoubleTapGesture -int 0
  printf "%s%s Disabled the two-finger Smart Zoom gesture\n" "${GREEN}" "${RESET}"

  defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false
  defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -int 0
  defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 1
  defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool true
  defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 1
  defaults write com.apple.preference.trackpad ForceClickSavedState -bool false
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

  defaults write com.apple.dock minimize-to-application -bool true
  printf "%s%s Minimized windows will be stored in their application icons\n" "${GREEN}" "${RESET}"

  defaults write com.apple.dock mru-spaces -bool false
  printf "%s%s Arrange spaces in custom order\n" "${GREEN}" "${RESET}"

  defaults write com.apple.dock showDesktopGestureEnabled -bool false
  defaults write com.apple.dock showLaunchpadGestureEnabled -bool false
  printf "%s%s Disabled trackpad gestures for showing the desktop and Launchpad\n" "${GREEN}" "${RESET}"

  defaults write com.apple.dock wvous-bl-corner -int 13
  defaults write com.apple.dock wvous-bl-modifier -int 0
  printf "%s%s Bottom-left Hot Corner will lock the screen\n" "${GREEN}" "${RESET}"

  # Finder
  defaults write com.apple.finder FXArrangeGroupViewBy -string "Name"
  defaults write com.apple.finder RecentsArrangeGroupViewBy -string "Date Last Opened"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
  printf "%s%s Configure Finder view\n" "${GREEN}" "${RESET}"

  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
  printf "%s%s Finder will show external and removable drives on the desktop\n" "${GREEN}" "${RESET}"

  defaults write com.apple.finder ShowRecentTags -bool false
  defaults write com.apple.finder ShowStatusBar -bool false
  defaults write com.apple.finder ShowPreviewPane -bool true
  defaults write com.apple.finder ShowSidebar -bool true
  defaults write com.apple.finder SidebarDevicesSectionDisclosedState -bool true
  defaults write com.apple.finder SidebariCloudDriveSectionDisclosedState -bool true
  defaults write com.apple.finder SidebarPlacesSectionDisclosedState -bool true
  defaults write com.apple.finder SidebarShowingiCloudDesktop -bool false
  defaults write com.apple.finder SidebarShowingSignedIntoiCloud -bool true
  printf "%s%s Configure Finder sidebar and panes\n" "${GREEN}" "${RESET}"

  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  printf "%s%s Finder will not create .DS_Store files on network volumes\n" "${GREEN}" "${RESET}"

  defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
  defaults write com.apple.WindowManager HideDesktop -bool true
  printf "%s%s Desktop icons will be hidden\n" "${GREEN}" "${RESET}"

  defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
  printf "%s%s Tiled windows will not have margins between them\n" "${GREEN}" "${RESET}"

  defaults write com.apple.WindowManager AppWindowGroupingBehavior -int 1
  defaults write com.apple.WindowManager AutoHide -bool true
  defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
  defaults write com.apple.WindowManager GloballyEnabled -bool false
  defaults write com.apple.WindowManager GloballyEnabledEver -bool true
  defaults write com.apple.WindowManager StageManagerHideWidgets -bool false
  defaults write com.apple.WindowManager StandardHideWidgets -bool false
  printf "%s%s Disable and configured Stage Manager\n" "${GREEN}" "${RESET}"

  # Menu bar and Control Center
  defaults write com.apple.menuextra.clock ShowAMPM -bool true
  defaults write com.apple.menuextra.clock ShowDate -int 0
  defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
  defaults write com.apple.menuextra.clock FlashDateSeparators -bool false
  defaults write com.apple.menuextra.clock Show24Hour -bool false
  defaults write com.apple.menuextra.clock ShowSeconds -bool false
  printf "%s%s Configure Menu bar clock\n" "${GREEN}" "${RESET}"

  defaults write com.apple.TextInputMenu visible -bool false
  for control_center_item in Battery Bluetooth Clock Sound WiFi; do
    defaults write com.apple.controlcenter "NSStatusItem VisibleCC ${control_center_item}" -bool true
  done
  printf "%s%s Battery, Bluetooth, clock, sound, and Wi-Fi will be available in Control Center\n" "${GREEN}" "${RESET}"

  mkdir -p "${HOME}/Documents/Screenshots"
  defaults write com.apple.screencapture location -string "${HOME}/Documents/Screenshots"
  defaults write com.apple.screencapture showsClicks -bool true
  defaults write com.apple.screencapture showsCursor -bool true
  printf "%s%s Configure screen capturing\n" "${GREEN}" "${RESET}"

  # Apps bundled with macOS

  defaults write com.apple.TextEdit RichText -int 0
  defaults write com.apple.TextEdit NSFixedPitchFont -string "Mononoki Nerd Font"
  defaults write com.apple.TextEdit NSFixedPitchFontSize -int 18
  defaults write com.apple.TextEdit ShowRuler -bool false
  defaults write com.apple.TextEdit CorrectSpellingAutomatically -bool false
  defaults write com.apple.TextEdit SmartCopyPaste -bool false
  defaults write com.apple.TextEdit SmartDashes -bool false
  defaults write com.apple.TextEdit SmartQuotes -bool false
  defaults write com.apple.TextEdit SmartSubstitutionsEnabledInRichTextOnly -bool false
  defaults write com.apple.TextEdit TextReplacement -bool false
  printf "%s%s Configure TextEdit\n" "${GREEN}" "${RESET}"

  defaults write com.apple.ActivityMonitor ShowCategory -int 100
  printf "%s%s Activity Monitor will show all processes\n" "${GREEN}" "${RESET}"

  defaults write com.apple.Terminal SecureKeyboardEntry -bool true
  printf "%s%s Enabled Secure Keyboard Entry in Terminal\n" "${GREEN}" "${RESET}"

  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
  printf "%s%s Raised the minimum Bluetooth audio bit pool for higher-quality audio\n" "${GREEN}" "${RESET}"

  defaults write com.apple.Preview PVInspectorWindowOpenOnStart -bool true
  defaults write com.apple.Preview PVMarkupToolbarVisibleForImages -bool true
  defaults write com.apple.Preview PVMarkupToolbarVisibleForPDFs -bool true
  printf "%s%s Preview will open its inspector and show markup tools for images and PDFs\n" "${GREEN}" "${RESET}"

  defaults write com.apple.keyboard.preferences IsMixmojiSuggestionsEnabled -bool false
  printf "%s%s Disabled Mixmoji suggestions\n" "${GREEN}" "${RESET}"

  # at the end
  killall SystemUIServer 2> /dev/null || true
  killall Finder 2> /dev/null || true
  killall Dock 2> /dev/null || true
  printf "%s%s Restarted UI elements so certain changes go into effect\n" "${GREEN}" "${RESET}"
}

function setup_shortcuts {
  readonly MOD_NONE=0
  readonly MOD_SHIFT=131072
  readonly MOD_CONTROL=262144
  readonly MOD_OPTION=524288
  readonly MOD_COMMAND=1048576
  readonly MOD_FUNCTION=8388608

  symbolic_hotkeys_plist="$(mktemp)"
  trap 'rm -f "${symbolic_hotkeys_plist}"' EXIT
  plutil -create xml1 "${symbolic_hotkeys_plist}"
  /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys dict" "${symbolic_hotkeys_plist}"

  # Screenshots - make clipboard copy the easier one
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 28 true "Save the screen to a file with Control-Command-Shift-3" 51 20 $((MOD_COMMAND | MOD_CONTROL | MOD_SHIFT))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 29 true "Copy the screen with Command-Shift-3" 51 20 $((MOD_COMMAND | MOD_SHIFT))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 30 true "Save the selected area to a file with Control-Command-Shift-4" 52 21 $((MOD_COMMAND | MOD_CONTROL | MOD_SHIFT))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 31 true "Copy the selected area with Command-Shift-4" 52 21 $((MOD_COMMAND | MOD_SHIFT))

  # Keyboard navigation configuration - disable all
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 12 false "Turn keyboard access on or off" 65535 122 $((MOD_FUNCTION | MOD_CONTROL))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 13 false "Change how Tab moves focus" 65535 98 $((MOD_FUNCTION | MOD_CONTROL))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 159 false "Show the contextual menu" 65535 36 ${MOD_CONTROL}

  # Accessibility display speech, captions, etc controls - disable all
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 15 false "Turn accessibility zoom on or off"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 16 false "Turn accessibility zoom on or off slowly (legacy companion)"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 17 false "Accessibility zoom in"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 18 false "Accessibility zoom in slowly (legacy companion)"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 19 false "Accessibility zoom out"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 20 false "Accessibility zoom out slowly (legacy companion)"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 21 false "Invert display colors"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 22 false "Invert display colors slowly (legacy companion)"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 23 false "Turn zoom image smoothing on or off"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 24 false "Turn zoom image smoothing on or off slowly (legacy companion)"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 25 false "Increase display contrast"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 26 false "Decrease display contrast"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 59 false "Turn VoiceOver on or off" 65535 96 $((MOD_FUNCTION | MOD_COMMAND))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 162 false "Show Accessibility controls" 65535 96 $((MOD_FUNCTION | MOD_COMMAND | MOD_OPTION))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 164 false "Legacy or reserved Notification Center shortcut" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 215 false "Turn Live Captions on or off" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 216 false "Pause or resume Live Captions transcription" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 217 false "Turn Live Captions Type to Speak on or off" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 218 false "Switch Live Captions between computer audio and microphone" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 219 false "Keep Live Captions onscreen" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 223 false "Turn the large Presenter Overlay on or off" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 224 false "Turn the small Presenter Overlay on or off" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 225 false "Turn Live Speech on or off" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 226 false "Toggle Live Speech visibility" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 227 false "Pause or resume Live Speech" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 228 false "Cancel Live Speech" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 229 false "Hide or show Live Speech phrases" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 230 false "Turn Speak Selection on or off" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 231 false "Turn Speak Item Under the Pointer on or off" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 232 false "Turn typing feedback on or off" 65535 65535 ${MOD_NONE}

  # Dock, Mission Control, and Spaces - disable all except space
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 33 false "Show application windows" 65535 125 $((MOD_FUNCTION | MOD_CONTROL))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 36 false "Show the desktop" 65535 103 ${MOD_FUNCTION}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 52 false "Turn Dock hiding on or off" 100 2 $((MOD_COMMAND | MOD_OPTION))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 79 true "Move to the previous Space"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 80 true "Move to the previous Space slowly (companion)"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 81 true "Move to the next Space"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 82 true "Move to the next Space slowly (companion)"
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 175 false "Turn Do Not Disturb on or off" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 190 false "Create a Quick Note" 113 12 ${MOD_FUNCTION}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 222 false "Turn Stage Manager on or off" 65535 65535 ${MOD_NONE}

  # Input sources, search, and help - disable all
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 60 false "Select the previous input source" 32 49 ${MOD_CONTROL}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 61 false "Select the next source in the Input menu" 32 49 $((MOD_CONTROL | MOD_OPTION))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 65 false "Show a Finder search window" 32 49 $((MOD_COMMAND | MOD_OPTION))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 98 false "Show the Help menu" 47 44 $((MOD_COMMAND | MOD_SHIFT))

  # Window management - disable all
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 233 false "Minimize the active window" 109 46 ${MOD_COMMAND}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 235 false "Zoom the active window" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 237 false "Fill the active window" 102 3 $((MOD_COMMAND | MOD_OPTION))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 238 false "Center the active window" 99 8 $((MOD_COMMAND | MOD_OPTION))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 239 false "Return the active window to its previous size" 114 15 $((MOD_FUNCTION | MOD_CONTROL))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 240 false "Tile the active window to the left half" 65535 123 $((MOD_FUNCTION | MOD_COMMAND | MOD_OPTION))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 241 false "Tile the active window to the right half" 65535 124 $((MOD_FUNCTION | MOD_COMMAND | MOD_OPTION))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 242 false "Tile the active window to the top half" 65535 126 $((MOD_FUNCTION | MOD_COMMAND | MOD_OPTION))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 243 false "Tile the active window to the bottom half" 65535 125 $((MOD_FUNCTION | MOD_COMMAND | MOD_OPTION))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 244 false "Tile the active window to the top-left quarter" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 245 false "Tile the active window to the top-right quarter" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 246 false "Tile the active window to the bottom-left quarter" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 247 false "Tile the active window to the bottom-right quarter" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 248 false "Arrange windows left and right" 65535 123 $((MOD_FUNCTION | MOD_CONTROL | MOD_SHIFT))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 249 false "Arrange windows right and left" 65535 124 $((MOD_FUNCTION | MOD_CONTROL | MOD_SHIFT))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 250 false "Arrange windows top and bottom" 65535 126 $((MOD_FUNCTION | MOD_CONTROL | MOD_SHIFT))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 251 false "Arrange windows bottom and top" 65535 125 $((MOD_FUNCTION | MOD_CONTROL | MOD_SHIFT))
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 256 false "Arrange windows in quarters" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 257 false "Full-screen tile a window to the left" 65535 65535 ${MOD_NONE}
  set_symbolic_hotkey "$symbolic_hotkeys_plist" 258 false "Full-screen tile a window to the right" 65535 65535 ${MOD_NONE}

  defaults import com.apple.symbolichotkeys "${symbolic_hotkeys_plist}"
  killall SystemUIServer 2> /dev/null || true
  printf "%s%s Applied macOS symbolic keyboard shortcuts\n" "${GREEN}" "${RESET}"
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

  # Login items
  for login_app in Hammerspoon Ghostty Maccy; do
    if [[ ! -d "/Applications/${login_app}.app" ]]; then
      printf "%s!%s Skipped missing login app %s\n" "${YELLOW}" "${RESET}" "${login_app}"
      continue
    fi
    if [[ "$(osascript -e "tell application \"System Events\" to login item \"${login_app}\" exists")" == "true" ]] \
      || osascript -e "tell application \"System Events\" to make login item at end with properties {name:\"${login_app}\", path:\"/Applications/${login_app}.app\", hidden:false}" > /dev/null; then
      printf "%s%s %s will open at login\n" "${GREEN}" "${RESET}" "${login_app}"
    else
      printf "%s!%s Could not add %s as a login item\n" "${YELLOW}" "${RESET}" "${login_app}"
    fi
  done

  overwrite_with_symlink "${CONFIG_HOME}/_editorconfig" "${HOME}/.editorconfig"
  mkdir -p "${HOME}/.ipython/profile_default/"
  overwrite_with_symlink "${CONFIG_HOME}/ipython_config.py" "${HOME}/.ipython/profile_default/ipython_config.py"
  mkdir -p "${HOME}/.config/gh-dash"
  overwrite_with_symlink "${CONFIG_HOME}/gh-dash-config.yml" "${HOME}/.config/gh-dash/config.yml"
  mkdir -p "${HOME}/.config/zed"
  overwrite_with_symlink "${CONFIG_HOME}/zed-settings.json" "${HOME}/.config/zed/settings.json"

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
  "shortcuts"
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
  elif [ "$module" = "shortcuts" ]; then
    printf "%s󰌌 Shortcuts%s\n" "${YELLOW}" "${RESET}"
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
  elif [ "$module" = "shortcuts" ]; then
    setup_shortcuts
  elif [ "$module" = "misc" ]; then
    setup_misc
  fi

  exec 1>&3 2>&4
  exec 3>&- 4>&-

  printf "╰─ %sFinished!%s\n\n" "${GREEN}" "${RESET}"
done

printf "All done!"
