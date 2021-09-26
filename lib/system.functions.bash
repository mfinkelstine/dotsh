#!/usr/bin/env bash

DOTSH=${HOME}"/.dotfiles"
DOTLIB=${DOTSH}"/lib"
DOTCONFIG=${HOME}"/.dotfiles/.config"
source ${DOTLIB}/logger.function.bash

system::is_plugin_enabled(){
	local file_name=$1
	
}

system::is_directory(){
	local dotsh_base_dir_name=$1
	local dotsh_dir_name=$2
	
	test -d $dotsh_base_dir_name/plugins/$dotsh_dir_name && echo True || echo False 

}
system::load_dotfiles() {
	# Load the shell dotfiles, and then some:
	# * ~/.path can be used to extend `$PATH`.
	# * ~/.extra can be used for other settings you don’t want to commit.
	local DOTSH_LOADINGFILES=$1
	if [[ -v ${DOTSH_LOADINGFILES} ]]; then
		printf " To load aliases you need to provide list of files name to load.\n" >&2
		printf " Seperatre each filename \," >/&2
		return 1
	fi
	#for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	for file in $(echo $DOTSH_LOADINGFILES | sed -e 's/,/ /g'); do
		file_name="${HOME}/.${file}"
		[ -r "$file_name" ] && [ -f "$file_name" ] && source "$file_name";
	done;
	unset file;
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

system::exists() {
	local command_exec=$1
	if ! command -v ${command_exec} >/dev/null; then
	  printf " ${command_exec} execute not found.\n" >/&2
	  printf " Please install ${command_exec} to use aliases.\n" >&2
	  return 1
	fi
}

system::setup_gitconfig(){

	GITCONFIG_LOCAL=${DOTCONFIG}"/git/.gitconfig.local"
	if ! [ -f  ${GITCONFIG_LOCAL} ]
	then
		logger "INFO" "Setting gitconfig File"
		git_credential='cache'
		if [ "$(uname -s)" == "Darwin" ]
		then
			git_credential='osxkeychain'
		fi
		user ' - What is your github author name?'
		read -e git_authorname
		user ' - What is your github author email?'
		read -e git_authoremail
		sed -i -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" ${GITCONFIG_LOCAL} 
		logger "INFO" "succesfully setup gitconfig file"
	fi
}

system::install_dotfiles() {
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find -H "${--DOTCONFIG}" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
  do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done


}

system::time(){
	# time 
	local date_format="$1"

	if [ ! -z ${date_format} ]; then 
		date_format="+%F %T %Z"
	fi

	echo $(date )
}

system::get_linkables() {
	find -H "$DOTFILES" -maxdepth 3 -name '*.symlink'
}

system::backup(){
	## Backup local dot files
	## BACKUP DIR
	## BACKUP DATE
	BACKUP_DIR=${HOME}/dotfiles-backup
	BACKUP_DATE=$(system::time "" )

    
	if [[ ! -d "$BACKUP_DIR" ]]; then
		echo "Creating backup directory at $BACKUP_DIR"
    	mkdir -p "$BACKUP_DIR"
	fi

    for file in $(get_linkables); do
        filename=".$(basename "$file" '.symlink')"
        target="$HOME/$filename"
        if [ -f "$target" ]; then
            echo "backing up $filename"
            cp "$target" "$BACKUP_DIR"
        else
            warning "$filename does not exist at this location or is a symlink"
        fi
    done

    for filename in "$HOME/.config/nvim" "$HOME/.vim" "$HOME/.vimrc"; do
        if [ ! -L "$filename" ]; then
            echo "backing up $filename"
            cp -rf "$filename" "$BACKUP_DIR"
        else
            warning "$filename does not exist at this location or is a symlink"
        fi
    done

}

system::symlinks(){
	    title "Creating symlinks"

    for file in $(get_linkables) ; do
        target="$HOME/.$(basename "$file" '.symlink')"
        if [ -e "$target" ]; then
            info "~${target#$HOME} already exists... Skipping."
        else
            info "Creating symlink for $file"
            ln -s "$file" "$target"
        fi
    done

    echo -e
    info "installing to ~/.config"
    if [ ! -d "$HOME/.config" ]; then
        info "Creating ~/.config"
        mkdir -p "$HOME/.config"
    fi

    config_files=$(find "$DOTFILES/config" -maxdepth 1 2>/dev/null)
    for config in $config_files; do
        target="$HOME/.config/$(basename "$config")"
        if [ -e "$target" ]; then
            info "~${target#$HOME} already exists... Skipping."
        else
            info "Creating symlink for $config"
            ln -s "$config" "$target"
        fi
    done

    # create vim symlinks
    # As I have moved off of vim as my full time editor in favor of neovim,
    # I feel it doesn't make sense to leave my vimrc intact in the dotfiles repo
    # as it is not really being actively maintained. However, I would still
    # like to configure vim, so lets symlink ~/.vimrc and ~/.vim over to their
    # neovim equivalent.

    echo -e
    info "Creating vim symlinks"
    VIMFILES=( "$HOME/.vim:$DOTFILES/config/nvim"
            "$HOME/.vimrc:$DOTFILES/config/nvim/init.vim" )

    for file in "${VIMFILES[@]}"; do
        KEY=${file%%:*}
        VALUE=${file#*:}
        if [ -e "${KEY}" ]; then
            info "${KEY} already exists... skipping."
        else
            info "Creating symlink for $KEY"
            ln -s "${VALUE}" "${KEY}"
        fi
    done
}

system::setup_git() {
    title "Setting up Git"

    defaultName=$(git config user.name)
    defaultEmail=$(git config user.email)
    defaultGithub=$(git config github.user)

    read -rp "Name [$defaultName] " name
    read -rp "Email [$defaultEmail] " email
    read -rp "Github username [$defaultGithub] " github

    git config -f ~/.gitconfig-local user.name "${name:-$defaultName}"
    git config -f ~/.gitconfig-local user.email "${email:-$defaultEmail}"
    git config -f ~/.gitconfig-local github.user "${github:-$defaultGithub}"

    if [[ "$(uname)" == "Darwin" ]]; then
        git config --global credential.helper "osxkeychain"
    else
        read -rn 1 -p "Save user and password to an unencrypted file to avoid writing? [y/N] " save
        if [[ $save =~ ^([Yy])$ ]]; then
            git config --global credential.helper "store"
        else
            git config --global credential.helper "cache --timeout 3600"
        fi
    fi



}