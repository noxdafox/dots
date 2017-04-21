# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# history
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%d/%m/%y %T "
## don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
## append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lessfile ] && eval "$(SHELL=/bin/bash lessfile)"
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/bash lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Environment variables
if [ -f ~/.environment ]; then
    . ~/.environment
fi

# Bash completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Configure colors
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_reset=$(tput sgr0)
    color_red=$(tput setaf 1)
    color_green=$(tput setaf 2)
    color_yellow=$(tput setaf 3)
    color_blue=$(tput setaf 4)
    color_neutral=$(tput setaf 7)
else
    color_reset=
    color_red=
    color_green=
    color_yellow=
    color_blue=
    color_neutral=
fi

# Print command information after execution
function pre_command() {
  if [ -z "$at_prompt" ]; then
    return
  fi
  unset at_prompt

  command_start=$SECONDS
}
trap "pre_command" DEBUG

first_prompt=1
function post_command() {
  at_prompt=1

  if [ -n "$first_prompt" ]; then
    unset first_prompt
    return
  fi

  duration=$(expr $SECONDS - $command_start)
  unset command_start

  log_command_status $return_code $duration
}

function command_exit_code() {
  return_code=$?
}

log_command_status() {
    duration="$2"
    timestamp=$(date -I'seconds')

    if [ $return_code -eq 0 ]; then
        color=$color_green
        status_message="OK"
    else
        color=$color_red
        status_message="ERROR: $return_code"
    fi

    printf "%s%*s%s\n" "$color" $COLUMNS \
           "[$timestamp] [$status_message] [$duration]" "$color_reset"
}

## Add the titlebar information when it is supported.
case $TERM in
xterm*|rxvt*)
    titlebar='\[\e]0;\u@\h: \w\a\]';
    ;;
*)
    titlebar="";
    ;;
esac

## Function to assemble the Git parsingart of our prompt.
git_prompt ()
{
    git_dir=`git rev-parse --git-dir 2>/dev/null`
    if [ -z "$git_dir" ]; then
        return 0
    fi
    git_head=`cat $git_dir/HEAD`
    git_branch=${git_head##*/}
    if [ ${#git_branch} -eq 40 ]; then
        git_branch="(no branch)"
    fi
    git_status=`git status --porcelain`
    if [ -z "$git_status" ]; then
        git_color="\[${color_neutral}\]"
    else
        echo -e "$git_status" | grep -q '^ [A-Z\?]'
        if [ $? -eq 0 ]; then
            git_color="\[${color_red}\]"
        else
            git_color="\[${color_green}\]"
        fi
    fi
    echo "[$git_color$git_branch$color_reset]"
}

PROMPT_COMMAND="command_exit_code
PS1=\"${titlebar}\[${color_green}\]\u\[${color_reset}\]@\[${color_green}\]\h\[${color_reset}\]:\[${color_blue}\]\w\[${color_reset}\]\$(git_prompt)\$ \"
post_command"
