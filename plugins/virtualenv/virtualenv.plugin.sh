function virtualenv_prompt_info(){
  [[ -n ${VIRTUAL_ENV} ]] || return
  echo "${ZSH_THEME_VIRTUALENV_PREFIX=[}${VIRTUAL_ENV:t:gs/%/%%}${ZSH_THEME_VIRTUALENV_SUFFIX=]}"
}

# disables prompt mangling in virtual_env/bin/activate
export VIRTUAL_ENV_DISABLE_PROMPT=1

# virtualenv
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Repos/git/
source /usr/local/bin/virtualenvwrapper.sh

alias venv="workon"
alias venv.exit="deactivate"
alias venv.ls="lsvirtualenv"
alias venv.show="showvirtualenv"
alias venv.init="mkvirtualenv"
alias venv.rm="rmvirtualenv"
alias venv.switch="workon"
alias venv.add="add2virtualenv"
alias venv.cd="cdproject"
alias venv.cdsp="cdsitepackages"
alias venv.cdenv="cdvirtualenv"
alias venv.lssp="lssitepackages"
alias venv.proj="mkproject"
alias venv.setproj="setvirtualenvproject"
alias venv.wipe="wipeenv"


export VENV_HOME=~/.venvs
export VENV_PYTHON=/usr/bin/python3.6
fn_workon() {
    if [ -f "${VENV_HOME}/${1}/bin/activate" ]; then
        export VENV_CURRENT="${VENV_HOME}/${1}"
        # Run commands before activation
        if [ -f "${VENV_CURRENT}/pre_activate.sh" ]; then
            . "${VENV_CURRENT}/pre_activate.sh"
        fi

        echo "Activating venv ${1}..."
        . "${VENV_CURRENT}/bin/activate"

        # Run commands after activation
        if [ -f "${VENV_CURRENT}/post_activate.sh" ]; then
            . "${VENV_CURRENT}/post_activate.sh"
        fi
    else
        echo "Could not find the venv '${1}'. Here is a list of venvs:"
        fn_lsvirtualenv
    fi
}
alias workon=fn_workon
fn_mkvirtualenv() {
    if [ -z "${VENV_HOME}" ]; then
        echo "VENV_HOME is not set; we don't know where to create your venv."
    else
        echo "Creating a new venv at: ${VENV_HOME}/${1}..."
        # Create the venv
        ${VENV_PYTHON} -m venv "${VENV_HOME}/${1}"

        # Create script to run before venv activation
        echo "# Commands to be run before venv activation" >> "${VENV_HOME}/${1}/pre_activate.sh"

        # Create script to run after venv activation, default to current directory
        echo "# Commands to be run after venv activation" >> "${VENV_HOME}/${1}/post_activate.sh"
        echo "cd ${PWD}" >> "${VENV_HOME}/${1}/post_activate.sh"

        # Activate the new venv
        fn_workon "${1}"

        # Get the latest pip
        echo "Upgradging to latest pip..."
        pip install --quiet --upgrade pip
    fi
}
alias mkvirtualenv=fn_mkvirtualenv
fn_rmvirtualenv() {
    if [ -z "${VENV_HOME}" ]; then
        echo "VENV_HOME is not set; not removing."
    else
        echo "Removing venv at: ${VENV_HOME}/${1}..."
        deactivate 2>/dev/null
        unset VENV_CURRENT
        rm -rf "${VENV_HOME}/${1}"
    fi
}
alias rmvirtualenv=fn_rmvirtualenv
fn_lsvirtualenv() {
    if [ -z "${VENV_HOME}" ]; then
        echo "VENV_HOME is not set; can not show venvs."
    else
        ls "${VENV_HOME}/" -1
    fi
}
alias lsvirtualenv=fn_lsvirtualenv
fn_cdvirtualenv() {
    cd "${VENV_CURRENT}"
}
alias cdvirtualenv=fn_cdvirtualenv