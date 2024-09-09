# Simple theme based on my old zsh settings.

function get_host {
    echo '@'`hostname`''
}

function get_aws_profile_prompt {
    if [[ "$AWS_PROFILE" == "" ]]; then
        return
    fi
    echo " | %{$fg[yellow]%} $(echo "$AWS_PROFILE" | cut -d- -f2-)%{$reset_color%}"
}

function get_k8s_context_prompt {
    if [[ ! -f ~/.kube/config ]]; then
        return
    fi
    local k8s_context=$(sed -n "s/^current-context: \(.*\)$/\1/p" ~/.kube/config)
    if [[ "$k8s_context" == "" ]]; then
        return
    fi
    echo " | %{$fg[blue]%}󱃾 $(echo "$k8s_context" | cut -d- -f1)%{$reset_color%}"
}

function get_venv_prompt {
    echo "$VIRTUAL_ENV_PROMPT" | perl -ne "s/(..*)/ | %F{#336c9d} \1%{$reset_color%}/g; print"
}

function get_git_prompt {
    echo "$(git_current_branch | cut -d- -f2- | perl -ne "s/(..*)/ | %F{#3fb951}\1%{$reset_color%}/g; print")"
}

PROMPT='
%F{#ffaf00}$(date +"%H:%M:%S %Z")  '
RPROMPT='%~%{${reset_color}%}$(get_git_prompt)$(get_venv_prompt)$(get_aws_profile_prompt)$(get_k8s_context_prompt)'
