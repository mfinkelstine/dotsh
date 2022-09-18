#!/bin/bash
shopt -s dotglob

cd "$(dirname "$0")"
INSTALL="sudo apt-get install -y"
DOTSH=$HOME/.dotfiles
#brew update
#brew install neovim packer ansible
#brew install cmake fish git python tmux tig htop jq ripgrep fzf yarn go
#brew install httpie nmap ipcalc rmtrash rlwrap ctags gradle python3 bat fd prettyping tldr ncdu
#brew install ssh-copy-id pidof tree reattach-to-user-namespace exa goreleaser gnu-sed
#brew cask install java alacritty aerial visual-studio-code
#
#brew tap tj/mmake https://github.com/tj/mmake.git
#brew install tj/mmake/mmake
#
#brew tap mitchellh/gon
#brew install mitchellh/gon/gon
#
#pip3 install virtualfish powerline-status pipenv neovim --user --upgrade
#pip3 install python-language-server pylint
#sudo pip3 install --upgrade neovim

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.cfnlintrc ~/.cfnlintrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/pylint.rc ~/pylint.rc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.ideavimrc ~/.ideavimrc
ln -s ~/dotfiles/.vim ~/
ln -s ~/dotfiles/.pip ~/
ln -s ~/dotfiles/.config ~/
ln -s ~/dotfiles/gradle.properties ~/.gradle/gradle.properties

if [ ! -e $HOME/.vim/autoload/plug.vim ]; then
  echo "Installing Plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Successfully updated dotfiles!"
echo " "

### Softlink to bash files
ln -sf ${HOME}/.dotfiles/.config/.bashrc ${HOME}/.bashrc
ln -sf ${HOME}/.dotfiles/.config/.bash_profile ${HOME}/.bash_profile
ln -sf ${HOME}/.dotfiles/.config/.history ${HOME}/.history

####### Verifications and backup #######

# Verification of the install dir
check_install_dir() {
  working -n "Checking dotfiles dir"
  log_cmd -c install-dir test "$(cd "$(dirname "$0")" && pwd)" = "$dir" || crash  "The dotfiles path is wrong! It should be ${dir}"
  cd $dir || crash "Cannot access $dir"
}

# create old_dotfiles in homedir
_backup_dir() {
  mkdir -p $olddir || return 1
  for file in $files; do
    if [ -f ~/."$file" -o -d ~/."$file" ]; then
      mv -f ~/."$file" "$olddir" || return 1
    fi
  done
}
backup_dir() {
  check_option backup && return 0
  local i tmp
  i=0
  tmp="$olddir"
  while [[ -d "$olddir" ]]; do
    ((i++))
    olddir="${tmp}-$i"
  done
  working -n "Backing up files to $olddir"
  log_cmd $0 _backup_dir || crash "Backup failed, aborting"
}

_symlinks() {
  for file in $files; do
    ln -s "${dir}/${file}" ~/."$file" || return 1
  done
}

symlink() {
  check_option link && return 0
  working -n "Symlinking dotfiles"
  log_cmd symlink _symlinks || fail "Symlink failed. Check logs at $LOG_DIR/symlink.err"
}


install_python() {
  check_option python && return 0
  local cmd
  if [[ "$OSX" ]]; then
    working -n "Installing Python"
    log_cmd python "$INSTALL" python || ko
  else
    if ! dpkg -s python-dev >/dev/null 2>/dev/null; then
      working -n "Installing Python"
      log_cmd python "$INSTALL" python-dev || ko
    fi
  fi
}

install_pip() {
  check_option python && return 0
  # brew installs pip by default
  if [[ ! "$OSX" ]]; then
    if ! dpkg -s python-pip >/dev/null 2>/dev/null; then
      working -n "Installing pip"
      log_cmd pip $INSTALL python-pip || ko
    fi
  fi
}

install_font() {
  if [[ "$OSX" ]]; then
    cp "$1" ~/Library/Fonts/ || return 1
  else
    mkdir -p ~/.fonts
    cp "$1" ~/.fonts/ || return 1
  fi
  return 0
}


check_installed_fonts() {
  # return as soon as we find a font that doesn't exist
  for f in $dir/powerline-fonts/*; do
    f=$(basename "$f")
    if [[ "$OSX" ]]; then
      [[ -f "~/Library/Fonts/$f" ]] || return 0
    else
      warning checking $f
      [[ -f "~/.fonts/$f" ]] || return 0
    fi
  done
  return 1
}

install_powerfonts() {
  check_option font && return 0
  if check_installed_fonts; then
    working -n "Copying powerline-fonts"
    log_cmd font-copy _install_powerfonts || fail "Could not copy the fonts. Check logs at $LOG_DIR"
    if [[ -z "$OSX" ]]; then
      working -n "Updating font cache"
      log_cmd font-cache fc-cache -fv || ko
    fi
    info "Remember to change the font to 'Liberation Mono for Powerline'"
  fi
}