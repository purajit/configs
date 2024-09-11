#/bin/bash
CONFIG_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$CONFIG_HOME"

if [[ "$1" == "fresh" ]]; then
    echo "Setting up from fresh! Will overwrite existing repos when needed"
    IS_FRESH=true
else
    echo "Not a fresh run"
    IS_FRESH=false
fi

# helpers
function overwrite_with_symlink {
    if [[ -L "$2" ]] && [[ "$(readlink "$2")" == "$1" ]]; then
        # symlink to expected file already exists, no action needed
        return
    fi
    ln -Fs "$1" "$2"
}

function clone_repo {
    repo="$1"
    folder="$(echo "$repo" | rev | cut -d/ -f1 | rev | cut -d. -f1)"
    [[ "$IS_FRESH" == "true" ]] \
        && rm -rf "$HOME/code/$folder" \
        && git clone "$repo" "$HOME/code/$folder"
}

# individual setup steps
function install_brew {
    echo "Setting up Homebrew ..."
    command -v brew &> /dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

function install_brewfile_formulae {
    echo "Installing from Brewfile ..."
    brew update
    brew bundle --file="$CONFIG_HOME/Brewfile"
    brew doctor
}

function setup_shell {
    echo "Setting up the shell ..."

    # common shell configs
    overwrite_with_symlink "$CONFIG_HOME/_aliases" "$HOME/.aliases"
    touch "$CONFIG_HOME/_zshlocal"
    overwrite_with_symlink "$CONFIG_HOME/_zshlocal" "$HOME/.zshlocal"

    # tools
    clone_repo "https://github.com/purajit/venv_manager.git"
    overwrite_with_symlink "$CONFIG_HOME/atuin-config.toml" "$HOME/.config/atuin/config.toml"

    # zsh
    overwrite_with_symlink "$CONFIG_HOME/_zshrc" "$HOME/.zshrc"
}

function setup_emacs {
    echo "Setting up Emacs ..."
    rm -f "$HOME/.emacs" "$HOME/.emacs.d"
    clone_repo "https://github.com/hlissner/doom-emacs"

    "$HOME/.config/emacs/bin/doom" install
    overwrite_with_symlink "$HOME/code/doom-emacs" "$HOME/.config/emacs"
    overwrite_with_symlink "$CONFIG_HOME/doom" "$HOME/.config/doom"
    "$HOME/.config/emacs/bin/doom" sync

    # run emacs server on startup
    overwrite_with_symlink "$CONFIG_HOME/emacs_launchd" "$HOME/Library/LaunchAgents/gnu.emacs.daemon.plist"
    if ! launchctl list gnu.emacs.daemon 1>/dev/null; then
        launchctl load -w "$HOME/Library/LaunchAgents/gnu.emacs.daemon.plist"
    fi
}

function setup_git {
    echo "Setting up git ..."
    overwrite_with_symlink "$CONFIG_HOME/_gitconfig" "$HOME/.gitconfig"
    overwrite_with_symlink "$CONFIG_HOME/_gitignore_global" "$HOME/.gitignore_global"
}

function setup_ipython {
    echo "Setting up IPython ..."
    mkdir -p "$HOME/.ipython/profile_default/"
    overwrite_with_symlink "$CONFIG_HOME/ipython_config.py" "$HOME/.ipython/profile_default/ipython_config.py"
}

function setup_iterm {
    echo "Setting up iTerm ..."
    rm "$HOME/Library/Preferences/com.googlecode.iterm2.plist"
    cp "$CONFIG_HOME/com.googlecode.iterm2.xml" "$CONFIG_HOME/com.googlecode.iterm2.plist"
    sed -i '' "s/{}/$USER/g" "$CONFIG_HOME/com.googlecode.iterm2.plist"
    plutil -convert binary1 com.googlecode.iterm2.plist
    # we can't symlink here, since iterm overwrites symlink'd configs
    mv "$CONFIG_HOME/com.googlecode.iterm2.plist" "$HOME/Library/Preferences/com.googlecode.iterm2.plist"
}

function setup_screenshots_dir {
    echo "Setting up screenshots directory ..."
    defaults write com.apple.screencapture location "$HOME/Documents/Screenshots"
    mkdir -p "$HOME/Documents/Screenshots"
    killall SystemUIServer
}

function setup_alacritty {
    echo "Setting up Alacritty ..."
    overwrite_with_symlink "$CONFIG_HOME/alacritty.toml" "$HOME/.config/alacritty.toml"
}

function setup_hammerspoon {
    echo "Setting up Hammerspoon ..."
    rm -rf "$HOME/.hammerspoon"
    overwrite_with_symlink "$CONFIG_HOME/_hammerspoon" "$HOME/.hammerspoon"
}

function setup_terraform {
    echo "Setting up Terraform ..."
    mkdir -p "$HOME/.terraform.d/plugin-cache"
    overwrite_with_symlink "$CONFIG_HOME/_terraformrc" "$HOME/.terraformrc"
}

function setup_tmux {
    echo "Setting up tmux ..."
    overwrite_with_symlink "$CONFIG_HOME/_tmux.conf" "$HOME/.tmux.conf"
}

function setup_ssh {
    echo "Setting up ssh ..."
    overwrite_with_symlink "$CONFIG_HOME/ssh_config" "$HOME/.ssh/config"
}

function setup_utils {
    echo "Setting up other system utils ..."
    if ! sudo launchctl list com.apple.locate 1>/dev/null; then
        sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
    fi
}

function setup_dot_config {
    echo "Setting up various ~/.config/ ..."
    overwrite_with_symlink "$CONFIG_HOME/wtfutil-config.yml" "$HOME/.config/wtf/config.yml"
    overwrite_with_symlink "$CONFIG_HOME/gh-dash-config.yml" "$HOME/.config/gh-dash/config.yml"
}

function setup_defaults {
    defaults write org.p0deje.Maccy clipboardCheckInterval 2
}

# first, a package manager
install_brew
install_brewfile_formulae

# then, the shell, terminal, editor
setup_shell
setup_alacritty
# setup_iterm
setup_emacs
setup_hammerspoon

# the rest
setup_dot_config
setup_git
setup_ipython
setup_screenshots_dir
setup_ssh
setup_terraform
setup_tmux
setup_utils
setup_defaults

echo "All done!"
