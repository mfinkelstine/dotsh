#!/usr/bin/env bash

# adding time to the commands because I'm very interested
# in how long these activities take with more complex builds
# across disparate platforms
command_exec="COMAND"

if ! command -v ${command_exec} >/dev/null; then
  printf " ${command_exec} execute not found.\n" >/&2
  printf " Please install ${command_exec} to use aliases.\n" >&2
  return 1
fi

## List of aliases to be exported when command is enabled
alias ALIAS_NAME='COMMAND_ALIAS'