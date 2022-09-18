#!/usr/bin/env bash
source $HOME/.dotfiles/lib/logger.sh
## Global Variables

aws_default_path="${HOME}/.aws"
aws_config_file="config"


function agp() {
  echo $AWS_PROFILE
}

# AWS profile selection
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

function aws_prompt_info() {
  [[ -z $AWS_PROFILE ]] && return
  echo "${ZSH_THEME_AWS_PREFIX:=<aws:}${AWS_PROFILE}${ZSH_THEME_AWS_SUFFIX:=>}"
}

function aws_set_source_file() {                                                               
    local aws_source_name=${1}
    unset AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID

    list_aws_profiles=$(ls $HOME/.aws/ | egrep -v "credentials|config")

    if [ ! -z ${aws_source_name} ]; then
        echo "You selected $aws_source_name"
    else
        select aws_profile_file in ${list_aws_profiles[@]}; do
            printf "[INFO ] Setting up AWS Credentials for account: %s\n" "${aws_profile_file}"
            source ${aws_default_path}/${aws_profile_file}
            break;
        done
    fi
}

function aws_set_default_profile() {
	local profile_name=${1}
	
	if [[ ! -d ${aws_default_path} ]] ; then
		printf "[ERROR] AWS Directory does not exist: %s\n " "${aws_default_path}"
	fi
	
	aws_profiles=($(cat ${aws_default_path}/${aws_config_file} | grep '\[profile' | sed -n 's/\[profile \(.*\).*\]/\1/p' | sort))
	if [[ -z ${profile_name} ]] ; then
	
	else
		select aws_profile in ${aws_profiles[@]}; do
			printf [
		done
	fi 		

}
function aws_profile(){


}

if [[ "$SHOW_AWS_PROMPT" != false && "$RPROMPT" != *'$(aws_prompt_info)'* ]]; then
  RPROMPT='$(aws_prompt_info)'"$RPROMPT"
fi

