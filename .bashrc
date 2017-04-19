# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# enable colors inside Emacs shell
if [ "$INSIDE_EMACS" ]; then
    export TERM=ansi COLORTERM=1
fi

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

# Set timestamps of command
log_command() {
    DURATION="$2"
    RESET_COLOR=$(tput sgr0)
    TIMESTAMP=$(date -I'seconds')

    if [ $RETURN_CODE -eq 0 ]; then
        COLOR=$(tput setaf 2)
        STATUS="OK"
    else
        COLOR=$(tput setaf 1)
        STATUS="ERROR: $RETURN_CODE"
    fi

    let COL=$(tput cols)

    printf "%s%*s%s\n" "$COLOR" $COL \
           "[$TIMESTAMP] [$STATUS] [$DURATION]" "$RESET_COLOR"
}

function exit_status() {
  RETURN_CODE=$?
}

function pre_commmand() {
  if [ -z "$AT_PROMPT" ]; then
    return
  fi
  unset AT_PROMPT

  COMMAND_START=$SECONDS
}
trap "pre_commmand" DEBUG

FIRST_PROMPT=1
function post_command() {
  AT_PROMPT=1

  if [ -n "$FIRST_PROMPT" ]; then
    unset FIRST_PROMPT
    return
  fi

  DURATION=$(expr $SECONDS - $COMMAND_START)
  unset COMMAND_START

  log_command $RETURN_CODE $DURATION
}

# Git prompt
## Configure colors, if available.
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    c_reset=$(tput sgr0)
    c_user=$(tput setaf 2)
    c_path=$(tput setaf 3)
    c_git_clean=$(tput setaf 7)
    c_git_staged=$(tput setaf 2)
    c_git_unstaged=$(tput setaf 1)
else
    c_reset=
    c_user=
    c_path=
    c_git_clean=
    c_git_staged=
    c_git_unstaged=
fi

## Add the titlebar information when it is supported.
case $TERM in
xterm*|rxvt*)
    TITLEBAR='\[\e]0;\u@\h: \w\a\]';
    ;;
*)
    TITLEBAR="";
    ;;
esac

## Function to assemble the Git parsingart of our prompt.
git_prompt ()
{
    GIT_DIR=`git rev-parse --git-dir 2>/dev/null`
    if [ -z "$GIT_DIR" ]; then
        return 0
    fi
    GIT_HEAD=`cat $GIT_DIR/HEAD`
    GIT_BRANCH=${GIT_HEAD##*/}
    if [ ${#GIT_BRANCH} -eq 40 ]; then
        GIT_BRANCH="(no branch)"
    fi
    STATUS=`git status --porcelain`
    if [ -z "$STATUS" ]; then
        git_color="${c_git_clean}"
    else
        echo -e "$STATUS" | grep -q '^ [A-Z\?]'
        if [ $? -eq 0 ]; then
            git_color="${c_git_unstaged}"
        else
            git_color="${c_git_staged}"
        fi
    fi
    echo "[$git_color$GIT_BRANCH$c_reset]"
}

PROMPT_COMMAND="exit_status
PS1=\"${TITLEBAR}${c_user}\u${c_reset}@${c_user}\h${c_reset}:${c_path}\w${c_reset}\$(git_prompt)\$ \"
post_command"
