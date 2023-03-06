# HISTORY AND PS
alias h='history -i'
alias hg='history -i | grep'
alias ps='ps aux'
alias psg='ps aux | grep'

# FILE SYSTEM
alias pu='pushd'
alias po='popd'

alias cp='cp -i'
alias mv='mv -i'

alias 'which'='which -a'
alias ls='ls -G'
alias lsa='ls -lah'
alias la='ls -la'
alias lt='ls -ltr'

alias rgrep='grep -r'
alias grepc='grep --color=always'

## INDEX
alias changemac="sudo ifconfig en0 ether $(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//')"
updatedb() {
    cd /
    sudo /usr/libexec/locate.updatedb
    cd -
}

## EMACS
alias emacs='/Applications/Emacs.app/Contents/MacOS/Emacs'
alias start_emacs='emacs --daemon'
alias kill_emacs='/Applications/Emacs.app/Contents/MacOS/bin/emacsclient -e "(kill-emacs)"'

emacsopen() {
    /Applications/Emacs.app/Contents/MacOS/bin/emacsclient $1 -c &
}

alias e=emacsopen
alias et='export TERM=xterm-256color && /Applications/Emacs.app/Contents/MacOS/bin/emacsclient -t'

# k8s
function kp {
    kubectl exec -it $(kubectl get pods -n $1 --no-headers -o custom-columns=":metadata.name" | head -1) -n $1 -- bash
}

# swap two files/folders
swap() {
    local TIMESTAMP=$(date "+%s")
    mv "$1" "$1.$TIMESTAMP"
    mv "$2" "$1"
    mv "$1.$TIMESTAMP" "$2"
}

# get parent folder of virtualenv location
function get_python_venv {
    if [[ -n "$VIRTUAL_ENV" ]] ; then
        echo "($(basename -- "$(dirname -- "$VIRTUAL_ENV")")) "
    fi
}

function sush {
    ssh -At $1 sudo su
}

## Tool-specific
function ap {
    export AWS_PROFILE=$1
}

## GIT HELPERS
function get_trunk {
    git remote show origin | sed -n '/HEAD branch/s/.*: //p'
}

alias gita='git commit -a --amend --no-edit'
alias gits='git status'
alias gitsh='git show | cat'
alias gitshf='git show --name-only | cat'
alias gitsw='git checkout -'
alias gtu='gt bs'
alias gtud='gt bs -d'
alias git-undo-wp-changes='git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -'

function gitr {
    if command -v gt &> /dev/null; then
        gt repo sync
    else
        trunk=$(get_trunk)
        git fetch origin && git rebase origin/$trunk
    fi
}

function gitb {
    if [ -z "$1" ]; then
        git branch
        return 0
    fi

    datestring=$(date +"%Y%m%d")
    branchname="$datestring-$1"

    frombranch="$2"
    if [ -z "$frombranch" ]; then
        frombranch=$(get_trunk)
    fi

    if command -v gt &> /dev/null; then
        if [[ "$frombranch" != "." && "$frombranch" != "$(git rev-parse --abbrev-ref HEAD)" ]]; then
            gt bco $frombranch
        fi
        gt bc --name $branchname ${@:3}
    else
        trunk="$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')"
        git checkout -b $branchname $frombranch ${@:2}
    fi
}

## VIDEO GAME HELPERS
function factorio_upload {
    cp "~/Library/Application Support/factorio/saves/$1.zip"  "/Volumes/GoogleDrive/My Drive/Personal/factorio-saves/"
}

function dont_starve_upload {
    destination=$(date "+%Y-%m-%d")
    cp -r "~/Library/Application Support/Steam/userdata/1021426716/219740/remote" "/Volumes/GoogleDrive/My Drive/Personal/dont-starve-saves/$destination"
}

function fix_itb {
    sed -i 'bkp' 's/\["iUndoTurn"\] = 0/["iUndoTurn"] = 1/g' ~/Library/Application\ Support/IntoTheBreach/profile_Alpha/saveData.lua
}
