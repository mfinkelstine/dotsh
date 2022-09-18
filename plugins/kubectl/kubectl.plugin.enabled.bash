#!/usr/bin/env bash

command_exec="kubectl"

if ! command -v ${command} >/dev/null; then
  printf " ${command} execute not found.\n" >/&2
  printf " Please install ${command} to use aliases.\n" >&2
  return 1
fi
ERROR_001="Please Use kgetns to list namespaces & use ksetns to set default namespace"

function ksetns(){
	local namespace=${1}

 	if [ -z ${namespace} ] ; then
		printf "[%-9s] %s\n" "ERROR" "You didnt Specifiy namespace"
		return 1
	fi
	ctx=$( kubectl config current-context )
	# verify that the namespace exists
	ns=$( kubectl get namespace ${namespace} --no-headers --output=go-template={{.metadata.name}} 2>/dev/null)

	if [ -z "${ns}" ] ; then
		printf "[WARNING] Namespace (%s) not found" "${namespace}"
	else
		export K8S_SET_NAMESPACE="${ns}"
		kubectl config set-context ${ctx} --namespace="${namespace}"
	fi
}

function ksetcontext(){

	local env_name=${1}
	#context_list=($(kubectl config  get-contexts -o=name | awk -F':' '{ { gsub("cluster/","") };print $4" "$6}'))
	context_list=$(kubectl config  get-contexts -o=name | sed -e 's/.*\///g')


	if [ ! -z ${env_name} ] ; then
	  	echo "You selected environment name: ${env_name}"
		for k8sconfig in ${context_list[@]}; do
			if [[ ${k8sconfig} == "*${env_name}*" ]] ; then
		  		echo "You selected environment name: ${env_name}"
			fi
		done
	else
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
	kubectl config use-context ${context_name} 2>&1 >/dev/null
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
NORMAL="\[\033[00m\]"
BLUE="\[\033[01;34m\]"
RED="\[\e[1;31m\]"
YELLOW="\[\e[1;33m\]"
GREEN="\[\e[1;32m\]"
#    "$(printf '\033[38;5;196m')"
#    "$(printf '\033[38;5;202m')"
#    "$(printf '\033[38;5;226m')"
#    "$(printf '\033[38;5;082m')"
#    "$(printf '\033[38;5;021m')"
#    "$(printf '\033[38;5;093m')"
#    "$(printf '\033[38;5;163m')"
bakwht='\e[47m'   # white
txtblu='\e[0;34m' # Blue

function __kube_ps1() {
    CONTEXT=$(kubectl config current-context)
    NAMESPACE=$(kubectl config view -o jsonpath="{.contexts[?(@.name==\"${CONTEXT}\")].context.namespace}")
    CONTEXT_SORT_NAME=$(echo $CONTEXT | sed -e 's/.*\///g')
    if [ -z "$NAMESPACE" ]; then
        NAMESPACE="default"
    fi
	kicon="${bakwht}${txtblu}⎈${NORMAL}"
    if [ -n "$CONTEXT" ]; then
        case "$CONTEXT" in
          *prod*)
            echo "${RED}${kicon} ${CONTEXT_SORT_NAME} - ${NAMESPACE})${NORMAL}"
            ;;
          *pre-prod*)
            echo "${RED}${kicon} ${CONTEXT_SORT_NAME} - ${NAMESPACE})${NORMAL}"
            ;;
          *sandbox*)
            echo "${YELLOW}${kicon} ${CONTEXT_SORT_NAME} - ${NAMESPACE})${NORMAL}"
            ;;
          *)
            echo "${GREEN}${kicon} ${CONTEXT_SORT_NAME} - ${NAMESPACE})${NORMAL}"
            ;;
        esac
    fi
}

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


# This command is used a LOT both below and in daily life
alias k="kubectl"
# Execute a kubectl command against all namespaces
alias kca='_kca(){ kubectl "$@" --all-namespaces;  unset -f _kca; }; _kca'
# Apply a YML file
alias kaf='kubectl apply -f'

# Drop into an interactive terminal on a container
alias keti='kubectl exec -ti'

# Manage configuration quickly to switch contexts between local, dev ad staging.
alias kcuc='kubectl config use-context'
alias kcsc='kubectl config set-context'
alias kcdc='kubectl config delete-context'
alias kccc='kubectl config current-context'

# List all contexts
alias kcgc='kubectl config get-contexts'

# General aliases
alias kdel='kubectl delete'
alias kdelf='kubectl delete -f'

# Pod management.
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'
# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kgp -l'
# get pod by namespace: kgpn kube-system"
alias kgpn='kgp -n'
# Service management.
alias kgs='kubectl get svc'
alias kgsa='kubectl get svc --all-namespaces'
alias kgsw='kgs --watch'
alias kgswide='kgs -o wide'
alias kes='kubectl edit svc'
alias kds='kubectl describe svc'
alias kdels='kubectl delete svc'

# Ingress management
alias kgi='kubectl get ingress'
alias kgia='kubectl get ingress --all-namespaces'
alias kei='kubectl edit ingress'
alias kdi='kubectl describe ingress'
alias kdeli='kubectl delete ingress'
# Namespace management
alias kgns='kubectl get namespaces'
alias kens='kubectl edit namespace'
alias kdns='kubectl describe namespace'
alias kdelns='kubectl delete namespace'
alias kcn='kubectl config set-context --current --namespace'
# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kgcma='kubectl get configmaps --all-namespaces'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl describe configmap'
alias kdelcm='kubectl delete configmap'
# Secret management
alias kgsec='kubectl get secret'
alias kgseca='kubectl get secret --all-namespaces'
alias kdsec='kubectl describe secret'
alias kdelsec='kubectl delete secret'
# Deployment management.
alias kgd='kubectl get deployment'
alias kgda='kubectl get deployment --all-namespaces'
alias kgdw='kgd --watch'
alias kgdwide='kgd -o wide'
alias ked='kubectl edit deployment'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'
kres(){
    kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}
# Rollout management.
alias kgrs='kubectl get rs'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'
# Statefulset management.
alias kgss='kubectl get statefulset'
alias kgssa='kubectl get statefulset --all-namespaces'
alias kgssw='kgss --watch'
alias kgsswide='kgss -o wide'
alias kess='kubectl edit statefulset'
alias kdss='kubectl describe statefulset'
alias kdelss='kubectl delete statefulset'
alias ksss='kubectl scale statefulset'
alias krsss='kubectl rollout status statefulset'
# Port forwarding
alias kpf="kubectl port-forward"
# Tools for accessing all information
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'
# Logs
alias kl='kubectl logs'
alias kl1h='kubectl logs --since 1h'
alias kl1m='kubectl logs --since 1m'
alias kl1s='kubectl logs --since 1s'
alias klf='kubectl logs -f'
alias klf1h='kubectl logs --since 1h -f'
alias klf1m='kubectl logs --since 1m -f'
alias klf1s='kubectl logs --since 1s -f'
# File copy
alias kcp='kubectl cp'
# Node Management
alias kgno='kubectl get nodes'
alias keno='kubectl edit node'
alias kdno='kubectl describe node'
alias kdelno='kubectl delete node'

# PVC management.
alias kgpvc='kubectl get pvc'
alias kgpvca='kubectl get pvc --all-namespaces'
alias kgpvcw='kgpvc --watch'
alias kepvc='kubectl edit pvc'
alias kdpvc='kubectl describe pvc'
alias kdelpvc='kubectl delete pvc'

# Service account management.
alias kgsa="kubectl get sa"
alias kdsa="kubectl describe sa"
alias kdelsa="kubectl delete sa"

# DaemonSet management.
alias kgds='kubectl get daemonset'
alias kgdsw='kgds --watch'
alias keds='kubectl edit daemonset'
alias kdds='kubectl describe daemonset'
alias kdelds='kubectl delete daemonset'

# CronJob management.
alias kgcj='kubectl get cronjob'
alias kecj='kubectl edit cronjob'
alias kdcj='kubectl describe cronjob'
alias kdelcj='kubectl delete cronjob'