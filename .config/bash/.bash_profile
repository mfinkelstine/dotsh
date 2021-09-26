# vi:syntax=sh

# Source .bashrc as recommended here:
# http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

if [ -f ~/.profile ]; then
   source ~/.profile
fi


## If not running interactively, don't do anything
#[[ $- != *i* ]] && return
#
#[[ -z "$WPATH" ]] && export WPATH="$(dirname "${BASH_SOURCE[0]}")"
#
#export LC_ALL="en_US.utf-8"
#export LC_CTYPE="en_US.utf-8"
#export LANG="en_US.utf-8"
## uncomment for a colored prompt, if the terminal has the capability; turned
## off by default to not distract the user: the focus in a terminal window
## should be on the output of commands, not on the prompt
#
#
## Alias definitions.
## You may want to put all your additions into a separate file like
## ~/.bash_aliases, instead of adding them here directly.
## See /usr/share/doc/bash-doc/examples in the bash-doc package.
#
#
## enable programmable completion features (you don't need to enable
## this, if it's already enabled in /etc/bash.bashrc and /etc/profile
## sources /etc/bash.bashrc).
#if ! shopt -oq posix; then
#  if [ -f /usr/share/bash-completion/bash_completion ]; then
#    . /usr/share/bash-completion/bash_completion
#  elif [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#  fi
#fi
#alias vi=vim
#nopource <(kubectl completion bash)
