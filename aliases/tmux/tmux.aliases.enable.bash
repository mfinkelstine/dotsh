#!/usr/bin/env bash

# adding time to the commands because I'm very interested
# in how long these activities take with more complex builds
# across disparate platforms

command="tmux"

if ! command -v ${command} >/dev/null; then
  printf " ${command} execute not found.\n" >/&2
  printf " Please install ${command} to use aliases.\n" >&2
  return 1
fi

# ALIASES TMUX Command aliases
alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'
