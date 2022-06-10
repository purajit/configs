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

git submodule update --recursive --init

# zsh
sh $CONFIG_HOME/zsh/setup.sh
touch $CONFIG_HOME/zsh/_zshwork
overwrite_with_symlink $CONFIG_HOME/zsh/_zshrc ~/.zshrc
overwrite_with_symlink $CONFIG_HOME/zsh/_zshwork ~/.zshwork
overwrite_with_symlink $CONFIG_HOME/zsh/_zprofile ~/.zprofile
overwrite_with_symlink $CONFIG_HOME/zsh/_zshenv ~/.zshenv

# oh-my-zsh
overwrite_with_symlink $CONFIG_HOME/zsh/_oh-my-zsh ~/.oh-my-zsh
overwrite_with_symlink $CONFIG_HOME/zsh/_oh-my-zsh_custom ~/.zshcustom

# bash
overwrite_with_symlink $CONFIG_HOME/bash/_bashrc ~/.bashrc
overwrite_with_symlink $CONFIG_HOME/bash/_bash_aliases ~/.bash_aliases

# emacs
sh $CONFIG_HOME/emacs/setup.sh
overwrite_with_symlink $CONFIG_HOME/emacs/_emacs ~/.emacs
overwrite_with_symlink $CONFIG_HOME/emacs/prelude ~/.emacs.d

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

# others
mkdir -p ~/.terraform.d/plugin-cache
overwrite_with_symlink $CONFIG_HOME/_terraformrc ~/.terraformrc
overwrite_with_symlink $CONFIG_HOME/_tmux.conf ~/.tmux.conf
overwrite_with_symlink $CONFIG_HOME/ssh_config ~/.ssh/config

sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

# brew
if [[ "$(arch)" == "i386" ]]; then
    local homebrew_dir=/opt/homebrew-x86_64
else
    local homebrew_dir=/opt/homebrew
fi
sudo mkdir -p $homebrew_dir && sudo chown -R $(whoami):admin $homebrew_dir && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $homebrew_dir
brew tap homebrew/cask-fonts
cat brew_packages.txt | xargs brew install

# set screenshots directory
defaults write com.apple.screencapture location ~/Documents/Screenshots
mkdir -p ~/Documents/Screenshots
killall SystemUIServer
