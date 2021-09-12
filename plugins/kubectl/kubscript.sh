#!/bin/bash

. ~/.dotfiles/.colors

ERROR_001="[ERROR] Please Use kconfig with env name e.g. dev/pre-prod/prod"
ERROR_002="[ERROR] Please Use kgetns to list namespaces & use ksetns to set default namespace"
ERROR_003="[ERROR] Please choose AWS Source from list awssourcelist command"

exports=( "awsset" "awssourcelist" )

function prompt { 
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] :\[\033[01;34m\]\w\[\033[00m\]\$ '
	if [[ ${SET_AWS_AUTH} == "true" ]]; then

		echo "SET AWS AUTHENTICATION"
		ENV_EXPORTED="${KUBEENV}"
	fi
        export	PS1=${PS1}
}


function _aws_caller_identity() {
	echo "aws sts get-caller-identity --query 'Account' --output text"
}

function _aws_account_alias(){
	echo "aws iam list-account-aliases --query 'AccountAliases[0]' --output text"
}


#### AWS Functions
function awssourcelist	{ ls -l ~/.aws/ ; }
function awsset { 
	local aws_auth_name=$1
	local aws_soruce_path="`pwd`/.aws"
	local aws_source_file
	unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

	[[ -f ${aws_soruce_path}"/aws-rnd-i2-${aws_auth_name}-box" ]] && aws_source_file="${aws_soruce_path}/aws-rnd-i2-${aws_auth_name}-box"
	[[ -f ${aws_soruce_path}"/"${aws_auth_name} ]] && aws_source_file="${aws_soruce_path}/${aws_auth_name}"
	if [[ ${aws_source_file} == "" ]] ; then
		echo -e "${ERROR_003}\n" ; 
	else
		printf "[INFO] aws config file %s\n" ${aws_source_file}
		export SET_AWS_AUTH="true"
		source ${aws_source_file}
	fi
	prompt
}

		
for export_name in ${exports[@]} ; do
	printf "[INFO] export %s\n" ${export_name}
	export -f ${export_name}
done

unset prompt
