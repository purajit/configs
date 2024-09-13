#!/usr/bin/env bash
CONFIG_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
RESET='\033[0m'

printf "Beginning configuration setup\n"
printf -- "- Using ${PURPLE}${CONFIG_HOME}${RESET}\n"
if [[ "$RECLONE" == "1" ]]; then
    printf -- "- ${RED}Will overwrite existing repos when needed${RESET}\n"
fi
printf "\n"

# helpers
function overwrite_with_symlink {
    # set -x
    if [[ -L "$2" && "$(readlink "$2")" = "$1" ]]; then
        # symlink to expected file already exists, no action needed
        printf "│ ${GREEN}${RESET} $2   $1\n"
        return
    elif [[ -d "$2" ]]; then
        rm -rfi "$2"
    fi
    ln -Fs "$1" "$2"
    printf "│ ${GREEN}${RESET} $2   $1\n"
}

function clone_repo {
    repo="$1"
    folder="$(echo "$repo" | rev | cut -d/ -f1 | rev | cut -d. -f1)"
    if [[ "$RECLONE" == "true" || ! -d "$HOME/code/$folder" ]]; then
        rm -rf "$HOME/code/$folder"
        git clone "$repo" "$HOME/code/$folder"
        printf "│ ${GREEN}${RESET} $repo   $HOME/code/$folder\n"
    else
        printf "│ ${GREEN}${RESET} $repo   $HOME/code/$folder\n"
    fi
}

# individual setup steps
function setup_brew {
    if command -v brew &> /dev/null; then
        printf "│ ${GREEN}${RESET} Homebrew already installed\n"
    else
        printf "│ ${YELLOW} ${RESET} Installing Homebrew\n"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew bundle --file="$CONFIG_HOME/Brewfile"
    brew doctor
}

function setup_shell {
    # common shell configs
    overwrite_with_symlink "$CONFIG_HOME/_aliases" "$HOME/.aliases"
    touch "$CONFIG_HOME/_zshlocal"
    printf "│ ${GREEN}${RESET} $CONFIG_HOME/_zshlocal ready\n"
    overwrite_with_symlink "$CONFIG_HOME/_zshlocal" "$HOME/.zshlocal"

    # shell tools
    clone_repo "https://github.com/purajit/venv_manager.git"
    overwrite_with_symlink "$CONFIG_HOME/atuin-config.toml" "$HOME/.config/atuin/config.toml"

    # ls colors via vivid + trapd00r
    mkdir -p "$HOME/.config/vivid/themes"
    overwrite_with_symlink "$CONFIG_HOME/vivid_trapd00r.yml" "$HOME/.config/vivid/themes/trapd00r.yml"

    # zsh
    overwrite_with_symlink "$CONFIG_HOME/_zshrc" "$HOME/.zshrc"
    overwrite_with_symlink "$CONFIG_HOME/_zprofile" "$HOME/.zprofile"
}

function setup_emacs {
    rm -f "$HOME/.emacs" "$HOME/.emacs.d"
    clone_repo "https://github.com/hlissner/doom-emacs.git"

    overwrite_with_symlink "$HOME/code/doom-emacs" "$HOME/.config/emacs"
    "$HOME/.config/emacs/bin/doom" install
    overwrite_with_symlink "$CONFIG_HOME/doom" "$HOME/.config/doom"
    "$HOME/.config/emacs/bin/doom" sync
}

function setup_git {
    overwrite_with_symlink "$CONFIG_HOME/_gitconfig" "$HOME/.gitconfig"
    overwrite_with_symlink "$CONFIG_HOME/_gitignore_global" "$HOME/.gitignore_global"
}

function setup_ipython {
    mkdir -p "$HOME/.ipython/profile_default/"
    overwrite_with_symlink "$CONFIG_HOME/ipython_config.py" "$HOME/.ipython/profile_default/ipython_config.py"
}

function setup_iterm {
    rm "$HOME/Library/Preferences/com.googlecode.iterm2.plist"
    cp "$CONFIG_HOME/com.googlecode.iterm2.xml" "$CONFIG_HOME/com.googlecode.iterm2.plist"
    sed -i '' "s/{}/$USER/g" "$CONFIG_HOME/com.googlecode.iterm2.plist"
    plutil -convert binary1 com.googlecode.iterm2.plist
    # we can't symlink here, since iterm overwrites symlink'd configs
    mv "$CONFIG_HOME/com.googlecode.iterm2.plist" "$HOME/Library/Preferences/com.googlecode.iterm2.plist"
}

function setup_screenshots_dir {
    defaults write com.apple.screencapture location "$HOME/Documents/Screenshots"
    mkdir -p "$HOME/Documents/Screenshots"
    printf "│ ${GREEN}${RESET} Screenshots will be stored in $HOME/Documents/Screenshots\n"
    killall SystemUIServer
}

function setup_alacritty {
    overwrite_with_symlink "$CONFIG_HOME/alacritty.toml" "$HOME/.config/alacritty.toml"
}

function setup_hammerspoon {
    overwrite_with_symlink "$CONFIG_HOME/_hammerspoon" "$HOME/.hammerspoon"
}

function setup_terraform {
    mkdir -p "$HOME/.terraform.d/plugin-cache"
    overwrite_with_symlink "$CONFIG_HOME/_terraformrc" "$HOME/.terraformrc"
}

function setup_tmux {
    overwrite_with_symlink "$CONFIG_HOME/_tmux.conf" "$HOME/.tmux.conf"
    mkdir -p "$HOME/.tmux/plugins"
    clone_repo "https://github.com/tmux-plugins/tpm.git"
    overwrite_with_symlink "$HOME/code/tpm" "$HOME/.tmux/plugins/tpm"

    install_plugins_script="$HOME/.tmux/plugins/tpm/bindings/install_plugins"
    [ -n "$TMUX" ] && "$install_plugins_script" || tmux new-session "$install_plugins_script"
    printf "│ ${GREEN}${RESET} Plugins installed\n"
}

function setup_ssh {
    overwrite_with_symlink "$CONFIG_HOME/ssh_config" "$HOME/.ssh/config"
}

function setup_utils {
    set -x
    if ! sudo launchctl list com.apple.locate 1>/dev/null; then
        sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
    fi
    set +x
}

function setup_dot_config {
    mkdir -p "$HOME/.config/wtf"
    mkdir -p "$HOME/.config/gh-dash"
    overwrite_with_symlink "$CONFIG_HOME/wtfutil-config.yml" "$HOME/.config/wtf/config.yml"
    overwrite_with_symlink "$CONFIG_HOME/gh-dash-config.yml" "$HOME/.config/gh-dash/config.yml"
}

function setup_defaults {
    defaults write org.p0deje.Maccy clipboardCheckInterval 2
    printf "│ ${GREEN}${RESET} Increase Maccy check interval to 2s\n"
}

ALL_MODULES=(
    # first, a package manager
    "brew"
    # then, the shell, terminal, editor
    "shell"
    "alacritty"
    "emacs"
    "hammerspoon"
    # the rest
    "dot_config"
    "git"
    "ipython"
    "screenshots_dir"
    "ssh"
    "terraform"
    "tmux"
    "utils"
    "defaults"
)

[[ "$#" == 1 && "$1" == "all" ]] && modules=("${ALL_MODULES[@]}") || modules=("$@")
for module in "${modules[@]}"; do
    printf "╭─ "
    bad_module=false
    if [ "$module" = "brew" ]; then
        printf "${YELLOW}${RESET}\n"
        setup_brew
    elif [ "$module" = "shell" ]; then
        printf "${YELLOW}  ${RESET}\n"
        setup_shell
    elif [ "$module" = "alacritty" ]; then
        printf "${YELLOW} ${RESET}\n"
        setup_alacritty
    elif [ "$module" = "tmux" ]; then
        printf "${YELLOW}${RESET}\n"
        setup_tmux
    elif [ "$module" = "emacs" ]; then
        printf "${YELLOW}${RESET}\n"
        setup_emacs
    elif [ "$module" = "hammerspoon" ]; then
        printf "${YELLOW}${RESET}\n"
        setup_hammerspoon
    elif [ "$module" = "dot_config" ]; then
        printf "${YELLOW}   󰘓${RESET}\n"
        setup_dot_config
    elif [ "$module" = "git" ]; then
        printf "${YELLOW}   ${RESET}\n"
        setup_git
    elif [ "$module" = "ipython" ]; then
        printf "${YELLOW}  ${RESET}\n"
        setup_ipython
    elif [ "$module" = "screenshots_dir" ]; then
        printf "${YELLOW} 󰹑${RESET}\n"
        setup_screenshots_dir
    elif [ "$module" = "ssh" ]; then
        printf "${YELLOW}  󰢭 󱫋${RESET}\n"
        setup_ssh
    elif [ "$module" = "terraform" ]; then
        printf "${YELLOW}󱁢 󰅟${RESET}\n"
        setup_terraform
    elif [ "$module" = "utils" ]; then
        printf "\n"
        setup_utils
    elif [ "$module" = "defaults" ]; then
        printf "\n"
        setup_defaults
    else
        printf "╰─ ${RED}Unknown module  $module  :c${RESET}\n"
        bad_module=true
    fi
    if [ "$bad_module" = "false" ]; then
        printf "╰─ ${GREEN}Finished setting up  ${module}  !${RESET}\n\n"
    fi
done

printf "\nAll done!"
