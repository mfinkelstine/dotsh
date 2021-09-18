#!/usr/bin/env bash

command_exec="kubectl"

if ! command -v ${command_exec} >/dev/null ; then
  printf "plugin: ${command_exec}  not found. Please install ${command_exec} before using this plugin." >&2
  return 1
fi

function ksetns(){
	local namespace=${1}

	ctx=`kubectl config current-context`
	# verify that the namespace exists
	ns=`kubectl get namespace ${namespace} --no-headers --output=go-template={{.metadata.name}} 2>/dev/null`

	if [ -z "${ns}" ] ; then
		printf "[WARNING] Namespace (%s) not found" "${namespace}"
	else
		export K8S_SET_NAMESPACE="${ns}"
		kubectl config set-context ${ctx} --namespace="${ns}"
	fi
}
function ksetcontext(){
	local env_name=${1}
	if [ ! -z ${env_name} ] ; then
	  	echo "You selected environment name: ${env_name}"
	else 
		context_list=$(kubectl config  get-contexts -o=name | sed -e 's/.*\///g')
		select context in ${context_list[@]}; do
	  		echo "You selected $context ($REPLY)"
			k8s::kusecontext ${context}
  			break;
		done
	fi	

}

function k8s::kusecontext(){
	local context_sort_name=${1}
	context_name=$( kubectl config  get-contexts -o name | grep ${context_sort_name})
	printf "[INFO] Kubernetes Context use: %s\n" ${context_name} 
	kubectl config  use-context ${context_name}	2>&1 >/dev/null
	aws::set_aws_profile ${context_sort_name}
}


function aws::set_aws_profile() {
	local aws_source_name=${1}
	unset AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID

	aws_default_path="${HOME}/.aws"
	list_aws_profiles=$(ls $HOME/.aws/ | egrep -v "credentials|config")
	if [ ! -z ${aws_source_name} ]; then
		profile_name=$(echo ${aws_source_name} | sed 's/i2-eks-\([^"]*\)-50/\1/')
		profile_exist=$(grep --color=never -Eo '\[.*\]' "${AWS_CONFIG_FILE:-$HOME/.aws/config}" | sed -E 's/^[[:space:]]*\[(profile)?[[:space:]]*([-_[:alnum:]\.@]+)\][[:space:]]*$/\2/g' | grep "^${profile_name}$")
		if [ -z $profile_exist ] ; then
			echo "profile ${profile_name} does not exist"
			return 1
		fi
		echo "You selected $aws_source_name export profile will be ${profile_name}"
		export AWS_PROFILE=${profile_name}
	else
		select aws_profile in ${list_aws_profiles[@]}; do
			printf "[INFO ] Setting up AWS Credentials for account: %s\n" "${aws_profile}"
			source ${aws_default_path}/${aws_profile}
			break;
		done
	fi 
}

ERROR_001="Please Use kgetns to list namespaces & use ksetns to set default namespace"



function psexport { 

	if [[ -z ${NAMESPACE} ]]
	then
		export PS1=${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[${NAMESPACE}\]\$ ; 
	elif [[ -z ${AWS_ENV} ]]
	then
		export PS1=${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[${AWS_ENV}\] \$ ; 
	elif [[ -z ${NAMESPACE} ]] && [[ -z ${AWS_ENV} ]] 
 	then
		export PS1=${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[${AWS_ENV}\] \[${NAMESPACE}\]\$ ; 
	elif [[ ! -z ${NAMESPACE} ]] && [[ ! -z ${AWS_ENV} ]]
	then
		export PS1=${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[${AWS_ENV}\] \[${NAMESPACE}\]\$ ; 
	fi

}


function kconfig { export KUBECONFIG=~/.kube/i2-eks-${1}-50 ; psexport ; }
function ksetns { export NAMESPACE=${1} ; psexport ;}

function kbash { kubectl exec -it bash ${NAMESPACE} ${1} ; }
function ksh { kubectl exec -it sh ${NAMESPACE} ${1} ; }

##### kubectl get
function kgetns   { kubectl get ns ; }
function knodes   { kubectl get nodes $@ ;}

function kgetpods   { if [[ -z  ${NAMESPACE} ]]; then kubectl -n ${NAMESPACE} get pods $@ ; else  echo -e "[ERROR] ${ERROR_001}"; fi ; }

function kgetpol  { kubectl -n ${NAMESPACE} get pods --show-labels ; }
function kgetsec  { kubectl -n ${NAMESPACE} get secret ; }
function kgetdeploy { kubectl -n ${NAMESPACE} get deployment ; }
function kgetsvc { kubectl -n ${NAMESPACE} get svc ; }
function kgetds { kubectl -n ${NAMESPACE} get deamonset ; }
function kgeting { kubectl -n ${NAMESPACE} get ing ; }
function kdiscribe { kubectl -n ${NAMESPACE} describe po ${1} ; }
##### kubectl logs
function klog { kubectl -n ${NAMESPACE} logs ${1} ; }
function klogl { kubectl -n ${NAMESPACE} logs ${1} -l ${2}; }
##### kubectl edit
function keditdeploy { kubectl -n ${NAMESPACE} edit deployment ${1} ; }
function keditcm { kubectl -n ${NAMESPACE} edit configmap ${1} ; }
function keditsec { kubectl -n ${NAMESPACE} edit secret ${1} ; }
function keditds { kubectl -n ${NAMESPACE} edit deamonset ${1} ; }
#function kedit { kubectl -n ${NAMESPACE} edit deployment ${1} ; }

#### AWS Functions
function awssourcelist	{ ls -l ~/.aws/ ; }
function awssource { source ~/.aws/aws-rnd-i2-${1}-box ; export AWS_ENV=${1} ; }

#### kubectl exports
export -f kconfig
export -f ksetns
#### kubectl export get
export -f kgetns
export -f kdiscribe 
export -f knodes
export -f kgetpods
export -f kgetpol
export -f kgetsec
export -f kgetdeploy
export -f kgetsvc
export -f kgetds
export -f kgeting 
export -f kbash
export -f klog
export -f klogl
export -f ksh

export -f keditdeploy
export -f keditcm
export -f keditsec
export -f keditds


#### aws exports
export -f awssourcelist
export -f awssource
