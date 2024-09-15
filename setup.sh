#!/usr/bin/env bash
CONFIG_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
        printf "│ %s%s %s   %s\n" "${GREEN}" "${RESET}" "$2" "$1"
        return
    elif [[ -d "$2" ]]; then
        rm -rf "$2"
    fi
    ln -Fs "$1" "$2"
    printf "│ %s%s %s   %s\n" "${GREEN}" "${RESET}" "$2" "$1"
}

function clone_repo {
    repo="$1"
    git_repo_folder="${HOME}/code/$(echo "$repo" | rev | cut -d/ -f1 | rev | cut -d. -f1)"
    if [[ "${RECLONE}" == "true" || ! -d "${git_repo_folder}" ]]; then
        rm -rf "${git_repo_folder}"
        GIT_TERMINAL_PROMPT=0 git clone --single-branch --recursive "${repo}" "${git_repo_folder}"
        printf "│ %s%s %s   %s\n" "${GREEN}" "${RESET}" "${repo}" "${git_repo_folder}"
    elif [[ -z "${DONT_PULL}" ]]; then
        GIT_TERMINAL_PROMPT=0 git -C "$git_repo_folder" pull
        GIT_TERMINAL_PROMPT=0 git -C "$git_repo_folder" submodule update --init --recursive
        printf "│ %s%s Pulled latest %s   %s\n" "${GREEN}" "${RESET}" "${repo}" "${git_repo_folder}"
    else
        printf "│ %s%s %s   %s\n" "${GREEN}" "${RESET}" "${repo}" "${git_repo_folder}"
    fi
}

# individual setup steps
function setup_init {
    printf "%s... init ...%s\n" "${YELLOW}" "${RESET}"
    mkdir -p "$HOME/.config/"
    printf "│ %s%s ~/.config present\n" "${GREEN}" "${RESET}"
}

function setup_brew {
    printf "%s  Brew, bundles%s\n" "${YELLOW}" "${RESET}"
    if command -v brew &>/dev/null; then
        printf "│ %s%s Homebrew already installed\n" "${GREEN}" "${RESET}"
    else
        printf "│ %s %s Installing Homebrew\n" "${YELLOW}" "${RESET}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew bundle --file="${CONFIG_HOME}/Brewfile"
    printf "│ %s%s Finished install from Brewfile\n" "${GREEN}" "${RESET}"
    brew doctor
}

function setup_shell {
    printf "%s zsh, tmux, Alacritty%s\n" "${YELLOW}" "${RESET}"

    # common shell configs
    overwrite_with_symlink "${CONFIG_HOME}/_aliases" "$HOME/.aliases"
    touch "${CONFIG_HOME}/_zshlocal"
    printf "│ %s%s %s/_zshlocal ready\n" "${GREEN}" "${RESET}" "${CONFIG_HOME}"
    overwrite_with_symlink "${CONFIG_HOME}/_zshlocal" "$HOME/.zshlocal"

    # LSCOLORS via vivid + trapd00r
    overwrite_with_symlink "${CONFIG_HOME}/_lscolors" "$HOME/.lscolors"
    # TODO: use vivid instead https://github.com/trapd00r/LS_COLORS/issues/195
    # mkdir -p "$HOME/.config/vivid/themes"
    # overwrite_with_symlink "${CONFIG_HOME}/vivid_trapd00r.yml" "$HOME/.config/vivid/themes/trapd00r.yml"

    # shell tools
    clone_repo "https://github.com/purajit/venv_manager.git"
    overwrite_with_symlink "${CONFIG_HOME}/atuin-config.toml" "$HOME/.config/atuin/config.toml"

    # zsh
    overwrite_with_symlink "${CONFIG_HOME}/_zshrc" "$HOME/.zshrc"
    overwrite_with_symlink "${CONFIG_HOME}/_zprofile" "$HOME/.zprofile"

    # tmux
    overwrite_with_symlink "${CONFIG_HOME}/_tmux.conf" "$HOME/.tmux.conf"

    # tmux plugins
    mkdir -p "$HOME/.tmux/plugins"
    clone_repo "https://github.com/fcsonline/tmux-thumbs.git"
    overwrite_with_symlink "$HOME/code/tmux-thumbs" "$HOME/.tmux/plugins/tmux-thumbs"
    clone_repo "https://github.com/tmux-plugins/tmux-cpu.git"
    overwrite_with_symlink "$HOME/code/tmux-cpu" "$HOME/.tmux/plugins/tmux-cpu"
    clone_repo "https://github.com/purajit/tmux-battery.git"
    overwrite_with_symlink "$HOME/code/tmux-battery" "$HOME/.tmux/plugins/tmux-battery"
    printf "│ %s%s Terraform plugins installed\n" "${GREEN}" "${RESET}"

    if [ -n "$TMUX" ]; then
        tmux source "${HOME}/.tmux.conf"
        printf "│ %s%s Active tmux session updated to latest configs\n" "${GREEN}" "${RESET}"
    fi

    # Alacritty
    overwrite_with_symlink "${CONFIG_HOME}/alacritty.toml" "${HOME}/.config/alacritty.toml"
}

function setup_automation {
    printf "%s󱚣  Automation tools%s\n" "${YELLOW}" "${RESET}"
    overwrite_with_symlink "${CONFIG_HOME}/_hammerspoon" "${HOME}/.hammerspoon"
}

function setup_emacs {
    printf "%s  Emacs%s\n" "${YELLOW}" "${RESET}"

    rm -f "$HOME/.emacs" "$HOME/.emacs.d"
    DONT_PULL=1 clone_repo "https://github.com/hlissner/doom-emacs.git"

    overwrite_with_symlink "$HOME/code/doom-emacs" "$HOME/.config/emacs"
    "$HOME/.config/emacs/bin/doom" install
    overwrite_with_symlink "${CONFIG_HOME}/doom" "$HOME/.config/doom"
    "$HOME/.config/emacs/bin/doom" sync
    printf "│ %s%s Installed and sync'd doomemacs\n" "${GREEN}" "${RESET}"
}

function setup_git {
    printf "%s  Git%s\n" "${YELLOW}" "${RESET}"
    overwrite_with_symlink "${CONFIG_HOME}/_gitconfig" "${HOME}/.gitconfig"
    overwrite_with_symlink "${CONFIG_HOME}/_gitignore_global" "${HOME}/.gitignore_global"
}

function setup_defaults {
    printf "%s defaults/plists%s\n" "${YELLOW}" "${RESET}"
    defaults write org.p0deje.Maccy clipboardCheckInterval 2
    printf "│ %s%s Increased Maccy check interval to 2s\n" "${GREEN}" "${RESET}"

    defaults write com.apple.screencapture location "${HOME}/Documents/Screenshots"
    mkdir -p "${HOME}/Documents/Screenshots"
    printf "│ %s%s Screenshots will be stored in %s/Documents/Screenshots\n" "${GREEN}" "${RESET}" "${HOME}"

    # at the end
    killall SystemUIServer
    printf "│ %s%s Restarted SystemUIServer so certain defaults go into effect\n" "${GREEN}" "${RESET}"
}

function setup_misc {
    printf "%s󱁢 m 󰅟  i    s  󰹑    c    🦀%s\n" "${YELLOW}" "${RESET}"

    if brew list rust &>/dev/null; then
        brew uninstall rust
        printf "│ %s%s Uninstalled Brew-maintained rust toolchain (in favor of rustup)\n" "${GREEN}" "${RESET}"
    fi

    if command -v cargo &>/dev/null; then
        printf "│ %s%s Rust 🦀 toolchain already installed\n" "${GREEN}" "${RESET}"
    else
        printf "│ %s %s Running rustup\n" "${YELLOW}" "${RESET}"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    fi

    mkdir -p "${HOME}/.ipython/profile_default/"
    overwrite_with_symlink "${CONFIG_HOME}/ipython_config.py" "${HOME}/.ipython/profile_default/ipython_config.py"
    mkdir -p "${HOME}/.config/gh-dash"
    overwrite_with_symlink "${CONFIG_HOME}/gh-dash-config.yml" "${HOME}/.config/gh-dash/config.yml"
    mkdir -p "${HOME}/.config/wtf"
    overwrite_with_symlink "${CONFIG_HOME}/wtfutil-config.yml" "${HOME}/.config/wtf/config.yml"
    mkdir -p "${HOME}/.ssh"
    overwrite_with_symlink "${CONFIG_HOME}/ssh_config" "$HOME/.ssh/config"
    overwrite_with_symlink "${CONFIG_HOME}/_terraformrc" "${HOME}/.terraformrc"
    mkdir -p "${HOME}/.terraform.d/plugin-cache"
    printf "│ %s%s Created Terraform global plugin cache\n" "${GREEN}" "${RESET}"
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
    bad_module=false
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
    else
        printf "\n╰─ %sUnknown module  %s  :c%s\n" "${RED}" "${module}" "${RESET}"
        bad_module=true
    fi
    if [ "$bad_module" = "false" ]; then
        printf "╰─ %sFinished!%s\n\n" "${GREEN}" "${RESET}"
    fi
done

printf "\nAll done!"
