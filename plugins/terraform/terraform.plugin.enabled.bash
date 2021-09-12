#!/usr/bin/env bash

# Terraform aliases
# adding time to the commands because I'm very interested
# in how long these activities take with more complex builds
# across disparate platforms

command="terraform"

if ! command -v ${command} >/dev/null; then
  printf " ${command} execute not found.\n" >/&2
  return 1
fi

function parse_tf_workspace() {
  [ -d ".terraform" ] && terraform workspace list 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (t:\1)/'
}

function tf_prompt_info() {
    # dont show 'default' workspace in home dir
    [[ "$PWD" == ~ ]] && return
    # check if in terraform dir
    if [[ -d .terraform && -r .terraform/environment  ]]; then
      workspace=$(cat .terraform/environment) || return
      echo "[${workspace}]"
    fi
}

