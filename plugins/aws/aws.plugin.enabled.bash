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

function hostname_from_instance() {
    echo $(aws ec2 describe-instances --instance-ids=$1 --query='Reservations[0].Instances[0].PublicDnsName' | tr -d '"')
}

function ip_from_instance() {
    echo $(aws ec2 describe-instances --instance-ids=$1 --query='Reservations[0].Instances[0].PublicIpAddress' | tr -d '"')
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

function awsenv() {
  if [ -z ${AWS_SECRET_ACCESS_KEY} ] && [ -z ${AWS_ACCESS_KEY_ID} ] ;then
  	printf "[INFO  ] You Are Working on %s" "${ENV_NAME}"
  else
	printf "[INFO ] %s\n" " NO ENV WAS DEFINED"
  fi
}

function awssetenv(){
	local env_name=$1
	printf "[INFO  ] AWS Configured %s" ${env_name}
  awschecksource() ${env_name}
  source ~/.aws/aws-rnd-i2-${env_name}-box
}

function awsunsetenv() {
	unset AWS_SECRET_ACCESS_KEY
	unset AWS_ACCESS_KEY_ID
	unset AWS_REGION
}

function awschecksource() {
  local env_name=$1
	printf "[INFO  ] Checking if AWS Configuration file exist %s" ${env_name}
  if [[ ! -e ~/.aws/aws-rnd-i2-${env_name}-box ]] ; then
    printf "[INFO ] AWS %s Environment does not exist please choose from list\n" ${env_name}
    awshelpenv()
	fi
}

function awshelpenv() {
	printf "[INFO  ] %s" "Please Choose environment type"
	printf "[INFO  ] \tAccount\t\tType\t\tPattern"
	printf "[INFO  ] \tSANDBOX\t\tsandbox\t%s" "sandbox || sandbox-api-gw"
	printf "[INFO  ] \tDEVELOPMENT\t\tdevelopment\t%s" "dev || dev-api-gw"
	printf "[INFO  ] \tPRE-PRODUCTION\t\tPRE-PRODUCTION\t%s" "pre-prod || pre-prod-api-gw"
	printf "[INFO  ] \tPRODUCTION \t\tPRODUCTION\t%s" "prod || prod-api-gw"
    exit 1
}


export -f awsenv
export -f awssetenv
export -f awsunsetenv