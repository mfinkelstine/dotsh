#!/usr/bin/env bash

# Terraform aliases
# adding time to the commands because I'm very interested
# in how long these activities take with more complex builds
# across disparate platforms

command="terraform"

if ! command -v ${command} >/dev/null; then
  printf " ${command} execute not found.\n" >/&2
  printf " Please install ${command} to use aliases.\n" >&2
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

function tfsetenv() {
  local AWSRootPath="${HOME}/.aws"
  local AWSProfileName=${1:-allenv}
  local AWSConfigFileName="${AWSRootPath}/config"
  local AWCCredentialsFileName="${AWSRootPath}/credentials"
  local AWSConfigFileNameSF="${AWSRootPath}/config.${AWSProfileName}"
  local AWSCredentialsFileNameSF="${AWSRootPath}/credentials.${AWSProfileName}"

  if [[ ${AWSProfileName} == "allenv" ]]; then
    printf "info" "Uing default AWS profile ${AWSProfileName}\n"
  fi

  if [ -L ${AWSConfigFileName} ] && [ "$(readlink -- "${AWSConfigFileName}")" == ${AWSConfigFileNameSF} ]; then
    unlink ~/.aws/config
  else
    rm -f ${AWSConfigFileName}
  fi

  if [ -L ${AWCCredentialsFileName} ] && [ "$(readlink -- "${AWSConfigFileName}")" == ${AWSCredentialsFileNameSF} ]; then
    unlink ~/.aws/credentials
  else
    rm -f ${AWCCredentialsFileName}
  fi

  printf "Creating credentials for Profile ${AWSProfileName}\n"
  ln -sF  ${AWSConfigFileNameSF} ${AWSConfigFileName}
  ln -sF ${AWSCredentialsFileNameSF} ${AWCCredentialsFileName}

}

function tfvalidate() {
  if test -f terragrunt.tf ; then
    mv terragrunt.tf terragrunt.tf.orig
  fi
  terraform init
  terraform validate
  mv terragrunt.tf.orig terragrunt.tf
}

function tfplan() {
  mv terragrunt.tf terragrunt.tf.orig
  terraform init
  terraform plan
  mv terragrunt.tf.orig terragrunt.tf
}


## List of aliases to be exported when command is enabled
alias tf='terraform'
alias tfi='terraform version'
alias tfi='terraform init'
alias tff='terraform fmt'
alias tfo='terraform output'
alias tfv='terraform validate'
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