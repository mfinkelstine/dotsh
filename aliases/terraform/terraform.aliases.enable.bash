#!/usr/bin/env bash

# adding time to the commands because I'm very interested
# in how long these activities take with more complex builds
# across disparate platforms
command="terraform"

if ! command -v ${command} >/dev/null; then
  printf " ${command} execute not found.\n" >/&2
  printf " Please install ${command} to use aliases.\n" >&2
  return 1
fi

## List of aliases to be exported when command is enabled
alias tf='terraform'
alias tfi='terraform version'
alias tfi='terraform init'
alias tfp='time terraform plan'
alias tfa='time terraform apply'
alias tfaa='time terraform apply -auto-approve '
alias tfd='time terraform destroy'
alias tfda='time terraform destroy -auto-approve '
alias twl='terraform workspace list '
alias tws='terraform workspace select '
alias twn='terraform workspace new '
# Terraform switch aliases
alias tsw='tfswitch -b ~/bin/terraform '
alias mya='source ~/myansible/bin/activate'