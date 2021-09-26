#!/usr/bin/env bash
#
# bootstrap installs things.

function _dotsh_show_usage() {
	echo -e "\n $0 : Install DOTSH (dot shell)"
	echo -e " Usage:\n$0 [arguments] \n"
	echo -e "\tArguments:"
	echo -e "\t --help (-h): Display this help message"
	echo -e "\t --silent (-s): Install default settings without prompting for input"
	echo -e "\t --interactive (-i): Interactively choose plugins"
	#echo "--no-modify-config (-n): Do not modify existing config file" #NOT IN USE
	#echo "--append-to-config (-a): Keep existing config file and append bash-it templates at the end" #NOT IN USE
	#echo "--overwrite-backup (-f): Overwrite existing backup" #NOT IN USE
	exit 0
}

cd "$(dirname "$0")/.."
DOTSH_ROOT=$(pwd -P)

set -e

source ${DOTSH_ROOT}/lib/logger.function.bash
source ${DOTSH_ROOT}/lib/system.functions.bash


for parm in "$@"; do
    shift
    case "$parm" in 
		"--help") set -- "$@" "-h" ;;
		"--silent") set -- "$@" "-s" ;;
		"--interactive") set -- "$@" "-i" ;;
        *) set -- "$@" "$param" ;;
    esac
done

OPTIND=1
while getopts "hsinaf" opt; do
	case "$opt" in
		"h")
			_dotsh_show_usage
			exit 0
			;;
		"s") silent=true ;;
		"i") interactive=true ;;
		#"n") no_modify_config=true ;;
		#"a") append_to_config=true ;;
		#"f") overwrite_backup=true ;;
		"?")
			_dotsh_show_usage >&2
			exit 1
			;;
	esac
done

shift $((OPTIND - 1))

