#!/usr/bin/env bash

source ${DOTLIB}/logger.function.bash

system::is_plugin_enabled(){
	local file_name=$1
	
}

system::is_directory(){
	local dotsh_base_dir_name=$1
	local dotsh_dir_name=$2
	
	test -d $dotsh_base_dir_name/plugins/$dotsh_dir_name && echo True || echo False 

}

system::load_plugins() {

	for plugin in $(ls ${DOTSH}/plugins/); do
		if [[ $(system::is_directory ${DOTSH} ${plugin})  == "True" ]] ;then
			for plugin_name in $(ls ${DOTSH}/plugins/${plugin}/*.enabled.bash 2>/dev/null); do 
				#echo -e "its file plugin: ${plugin_name}\n" ; 
				source "${plugin_name}"
			done 
		fi
	done

}

system::exists() {
  command -v $1 > /dev/null 2>&1
}
