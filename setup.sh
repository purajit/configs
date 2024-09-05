#/bin/bash
CONFIG_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$CONFIG_HOME"

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
    rm -rf "$HOME/code/$folder"
    git clone "$repo" "$HOME/code/$folder"
}

# individual setup steps
function install_brew {
    echo "Setting up Homebrew ..."
    if [[ "$1" == "true" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

function install_brewfile_formulae {
    echo "Installing from Brewfile ..."
    brew update
    brew bundle --file="$CONFIG_HOME/Brewfile"
    brew doctor
}

function setup_bash_zsh {
    echo "Setting up bash, oh-my-zsh, zsh ..."

    # bash
    overwrite_with_symlink "$CONFIG_HOME/bash/_bashrc" "$HOME/.bashrc"
    overwrite_with_symlink "$CONFIG_HOME/bash/_bash_aliases" "$HOME/.bash_aliases"

    # oh-my-zsh
    if [[ "$1" == "true" ]]; then
        clone_repo "https://github.com/robbyrussell/oh-my-zsh.git"
        clone_repo "https://github.com/purajit/venv_manager.git"
    fi
    overwrite_with_symlink "$HOME/code/oh-my-zsh" "$HOME/.oh-my-zsh"
    overwrite_with_symlink "$CONFIG_HOME/zsh/_oh-my-zsh_custom" "$HOME/.zshcustom"

    # zsh
    mkdir -p "$HOME/.zshcustom/plugins"
    overwrite_with_symlink "$HOME/code/venv_manager" "$HOME/.zshcustom/plugins/venv_manager"
    overwrite_with_symlink "$CONFIG_HOME/zsh/_zshrc" "$HOME/.zshrc"
    overwrite_with_symlink "$CONFIG_HOME/zsh/_zshwork" "$HOME/.zshwork"
    overwrite_with_symlink "$CONFIG_HOME/zsh/_zshenv" "$HOME/.zshenv"

    source ~/.zshrc
}

function setup_emacs {
    echo "Setting up Emacs ..."
    if [[ "$1" == "true" ]]; then
        rm -f "$HOME/.emacs"
        # install Doomemacs
        clone_repo "https://github.com/hlissner/doom-emacs"
        overwrite_with_symlink "$HOME/code/doom-emacs" "$HOME/.config/emacs"
        doom install
    fi

    doom sync

    # run emacs server on startup
    overwrite_with_symlink "$CONFIG_HOME/emacs/launchd" "$HOME/Library/LaunchAgents/gnu.emacs.daemon.plist"
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
    mkdir -p "$HOME/.hammerspoon" "$HOME/.config"
    overwrite_with_symlink "$CONFIG_HOME/hammerspoon-init.lua" "$HOME/.hammerspoon/init.lua"
    overwrite_with_symlink "$CONFIG_HOME/alacritty.yml" "$HOME/.config/alacritty.yml"
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

if [[ "$1" == "fresh" ]]; then
    echo "Setting up from fresh!"
    is_fresh=true
else
    echo "Not a fresh run"
    is_fresh=false
fi

# first, a package manager
install_brew "$is_fresh"
install_brewfile_formulae "$is_fresh"

# then, the shell, terminal, editor
setup_bash_zsh "$is_fresh"
# setup_alacritty "$is_fresh"  # Not using Alacritty due to lack of cmd-as-meta
setup_iterm "$is_fresh"
setup_emacs "$is_fresh"

# the rest
setup_dot_config "$is_fresh"
setup_git "$is_fresh"
setup_ipython "$is_fresh"
setup_screenshots_dir "$is_fresh"
setup_ssh "$is_fresh"
setup_terraform "$is_fresh"
setup_tmux "$is_fresh"
setup_utils "$is_fresh"
