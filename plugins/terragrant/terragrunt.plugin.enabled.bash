#!/usr/bin/env bash

# terragrant aliases & Functions
# adding time to the commands because I'm very interested
# in how long these activities take with more complex builds
# across disparate platforms

command="terragrant"

if ! command -v ${command} >/dev/null; then
  printf " ${command} execute not found.\n" >/&2
  printf " Please install ${command} to use aliases.\n" >&2
  return 1
fi

function parse_tf_workspace() {
  [ -d ".terraform" ] && terraform workspace list 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (t:\1)/'
}



function tgplan() {
  local terragruntworkingdirectory=${1}
  local options=${2:-???}
  #terragrunt plan --terragrunt-working-dir ${terragruntworkingdirectory} --terragrunt-non-interactive 
  #terragrunt apply --terragrunt-working-dir ./dev/AWS/chkp-aws-rnd-i2-api-gw-dev-box/eu-west-1/ec2-syslog/ --terragrunt-non-interactive -auto-approve
}