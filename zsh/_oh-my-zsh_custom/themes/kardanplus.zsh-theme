# Simple theme based on my old zsh settings.

function get_host {
    echo '@'`hostname`''
}

function get_aws_profile {
    if [[ "$AWS_PROFILE" == "" ]]; then
        echo ""
        return
    fi
    echo "%{$fg[yellow]%}$AWS_PROFILE + %{$reset_color%}"
}

function get_k8s_context {
    if [[ ! -f ~/.kube/config ]]; then
        return
    fi
    local k8s_context=$(sed -n "s/^current-context: \(.*\)$/\1/p" ~/.kube/config)
    if [[ "$k8s_context" == "" ]]; then
        return
    fi
    echo "%{$fg[blue]%}$k8s_context + %{$reset_color%}"
}

function print_symlink {
    local wd="$(pwd)"
    local linkdir="$(readlink -n $wd)";
    if readlink -n $wd >/dev/null; then
        echo " -> $linkdir";
    fi
}

PROMPT='
%{$fg[yellow]%}[$(date +"%H:%M:%S %Z")] $(get_aws_profile)$(get_k8s_context)%{$fg[green]%}%~$(print_symlink) $(git_prompt_info)
%{$fg[yellow]%}$(get_python_venv)%{$fg_bold[red]%}λ $(whoami) %{$fg_bold[red]%}➜%{$reset_color%}  '

ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
