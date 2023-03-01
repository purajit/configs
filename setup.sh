#/bin/bash
CONFIG_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $CONFIG_HOME

function overwrite_with_symlink {
    if [ -L $2 ] && [ $(readlink $2) == $1 ]; then
        # symlink to expected file already exists
        return
    fi
    ln -Fs $1 $2
}

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file=$CONFIG_HOME/Brewfile

# repos used
rm -rf ~/code/venv_manager ~/code/oh-my-zsh ~/code/spacemacs
git clone https://github.com/purajit/venv_manager.git ~/code/venv_manager
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/code/oh-my-zsh
git clone https://github.com/syl20bnr/spacemacs.git ~/code/spacemacs

# bash
overwrite_with_symlink $CONFIG_HOME/bash/_bashrc ~/.bashrc
overwrite_with_symlink $CONFIG_HOME/bash/_bash_aliases ~/.bash_aliases

# oh-my-zsh
overwrite_with_symlink ~/code/oh-my-zsh ~/.oh-my-zsh
overwrite_with_symlink $CONFIG_HOME/zsh/_oh-my-zsh_custom ~/.zshcustom

# zsh
touch $CONFIG_HOME/zsh/_zshwork
overwrite_with_symlink ~/code/venv_manager ~/.zshcustom/plugins/venv_manager
overwrite_with_symlink $CONFIG_HOME/zsh/_zshrc ~/.zshrc
overwrite_with_symlink $CONFIG_HOME/zsh/_zshwork ~/.zshwork
overwrite_with_symlink $CONFIG_HOME/zsh/_zshenv ~/.zshenv

# emacs
rm ~/.emacs.d
overwrite_with_symlink $CONFIG_HOME/_emacs ~/.emacs
overwrite_with_symlink ~/code/spacemacs ~/.emacs.d

# git
overwrite_with_symlink $CONFIG_HOME/_gitconfig ~/.gitconfig
overwrite_with_symlink $CONFIG_HOME/_gitignore_global ~/.gitignore_global

# ipython
mkdir -p ~/.ipython/profile_default/
overwrite_with_symlink $CONFIG_HOME/ipython_config.py ~/.ipython/profile_default/ipython_config.py

# iterm
cp $CONFIG_HOME/com.googlecode.iterm2.xml $CONFIG_HOME/com.googlecode.iterm2.plist
sed -i '' "s/{}/$USER/g" $CONFIG_HOME/com.googlecode.iterm2.plist
plutil -convert binary1 com.googlecode.iterm2.plist
overwrite_with_symlink $CONFIG_HOME/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
# Alacritty
mkdir -p ~/.hammerspoon ~/.config
overwrite_with_symlink $CONFIG_HOME/hammerspoon-init.lua ~/.hammerspoon/init.lua
overwrite_with_symlink $CONFIG_HOME/alacritty.yml ~/.config/alacritty.yml

# others
mkdir -p ~/.terraform.d/plugin-cache
overwrite_with_symlink $CONFIG_HOME/_terraformrc ~/.terraformrc
overwrite_with_symlink $CONFIG_HOME/_tmux.conf ~/.tmux.conf
overwrite_with_symlink $CONFIG_HOME/ssh_config ~/.ssh/config
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

# set screenshots directory
defaults write com.apple.screencapture location ~/Documents/Screenshots
mkdir -p ~/Documents/Screenshots
killall SystemUIServer
