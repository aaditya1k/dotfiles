# History command configuration
setopt extended_history         # record timestamp of command in HISTFILE
setopt hist_expire_dups_first   # delete duplicates first when HISTFILE size exceeds HISTSIZE
# setopt hist_ignore_dups       # ignore duplicated commands history list
setopt HIST_IGNORE_ALL_DUPS     # If a new command line being added to the history list duplicates an older one,
                                # the older command is removed from the list (even if it is not the previous event).
setopt hist_ignore_space        # ignore commands that start with space
setopt hist_verify              # show command with history expansion to user before running it
setopt share_history            # share command history data

export CLICOLOR=1               # By enabling this ls will also run as "ls -G"
export LSCOLORS=ExFxBxDxCxegedabagacad


# Simple ROMPT
autoload -U colors && colors
autoload -Uz vcs_info
precmd() {
    vcs_info
}
zstyle ':vcs_info:git:*' formats '[%b]' # Format the vcs_info_msg_0_ variable
setopt PROMPT_SUBST             # Set up the prompt (with git branch name)

# %3~ : only last 3 working directory will come in prompt
PS1='%F{white}%3~%F{blue}${vcs_info_msg_0_}%F{green}$%{$reset_color%} '
# End of PROMPT


export NODE_REPL_HISTORY=""     # Disable ~/.node_repl_history

source ~/dotfiles/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/dotfiles/utils/battery.sh
source ~/dotfiles/utils/aws.sh


# Docker
alias dkps="docker ps --format=\"table{{.ID}} {{.Names}}\" | sort --key=2"
alias dkkill="docker kill \$(docker ps -q)"
alias dkup="docker-compose up -d"
alias dkdown="docker-compose down"
dkexe() {
    docker_processes=$(docker ps --format="{{.ID}} {{.Names}}")

    re='^[0-9]+$'
    if ! [[ $1 =~ $re ]] ;then
        # Not a number, searching by container name
        container_search=$(echo "$docker_processes" | grep $1)
    else
        # searching by starting of container id
        container_search=$(echo "$docker_processes" | grep ^$1)
    fi

    if [ -z $container_search ] ;then
        echo "\nNo container found!\n"
        dkps
        return 0
    fi

    lines=$(echo $container_search | wc -l)
    if [ $lines -gt 1 ] ;then
        echo "\nFound more than 1 containers"
        echo "$container_search"
        container_search=$(echo $container_search | head -n 1)
    fi

    container_id=$(echo "$container_search" | awk '{print $1}')
    echo "\n-- Connecting $container_search --"

    if [ $# -gt 1 ] ;then
        docker exec -it "$container_id" ${@:2} # Skip first argument and pass all other
    else
        docker exec -it "$container_id" bash
    fi
}

# misc.
alias audio-dl="youtube-dl $1 -x --audio-quality=0 $2"
alias paste_json="pbpaste | json_pp"
alias pretty_json="pbpaste | json_pp | bat -l json"

# git
alias git_log="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
