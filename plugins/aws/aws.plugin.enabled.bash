#!/usr/bin/env bash

function agp() {
  echo $AWS_PROFILE
}

function asp() {
  if [[ -z "$1" ]]; then
    unset AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE
    echo AWS profile cleared.
    return
  fi

  local -a available_profiles
  available_profiles=($(aws_profiles))
  if [[ -z "${available_profiles[(r)$1]}" ]]; then
    echo "${fg[red]}Profile '$1' not found in '${AWS_CONFIG_FILE:-$HOME/.aws/config}'" >&2
    echo "Available profiles: ${(j:, :)available_profiles:-no profiles found}${reset_color}" >&2
    return 1
  fi

  export AWS_DEFAULT_PROFILE=$1
  export AWS_PROFILE=$1
  export AWS_EB_PROFILE=$1
}

function _aws_profiles() {
  reply=($(aws_profiles))
}


function aws_profiles() {
  [[ -r "${AWS_CONFIG_FILE:-$HOME/.aws/config}" ]] || return 1
  grep --color=never -Eo '\[.*\]' "${AWS_CONFIG_FILE:-$HOME/.aws/config}" | sed -E 's/^[[:space:]]*\[(profile)?[[:space:]]*([-_[:alnum:]\.@]+)\][[:space:]]*$/\2/g'
}

complete -F  _aws_profiles asp acp aws_change_access_key

# AWS prompt
function aws_prompt_info() {
  [[ -z $AWS_PROFILE ]] && return
  echo "${DOTSH_THEME_AWS_PREFIX:=<aws:}${AWS_PROFILE}${DOTSH_THEME_AWS_SUFFIX:=>}"
}

if [[ "$SHOW_AWS_PROMPT" != false && "$RPROMPT" != *'$(aws_prompt_info)'* ]]; then
  RPROMPT='$(aws_prompt_info)'"$RPROMPT"
fi

