# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# history
HISTSIZE=10000
HISTFILESIZE=20000
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

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

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

# Git holy prompt
## Configure colors, if available.
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    c_reset='\[\e[0m\]'
    c_user='\[\e[0;32m\]'
    c_path='\[\e[1;34m\]'
    c_git_clean='\[\e[0;37m\]'
    c_git_staged='\[\e[0;32m\]'
    c_git_unstaged='\[\e[0;31m\]'
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

## Thy holy prompt.
PROMPT_COMMAND="$PROMPT_COMMAND PS1=\"${TITLEBAR}${c_user}\u${c_reset}@${c_user}\h${c_reset}:${c_path}\w${c_reset}\$(git_prompt)\$ \" ;"
