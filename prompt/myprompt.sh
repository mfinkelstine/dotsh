# Add to your /home/user/binthis folder

# Ugly. Yes. It just works.

function myprompt() {
    CLS=$( kubectl config get-contexts | grep "*" | awk '{ print $2 " " $5}' )
    KCONTEXT="🔯 → $(echo $CLS | cut -f1 -d " ")/$( echo $CLS | cut -f2 -d " ")"
    KLOGO_COLOR="\e[30;1;34m"
    KCTX_COLOR="\e[33;0;33m"
    K="${KLOGO_COLOR}[ ${KCTX_COLOR}${KCONTEXT}${KLOGO_COLOR} ]"

    DCONTEXT="🐳 → $(command docker context ls | grep '*' | cut -f 1 -d ' ')"
    DLOGO_COLOR="\e[30;1;34m"
    DCTX_COLOR="\e[33;0;33m"
    D="${DLOGO_COLOR}[ ${DCTX_COLOR}${DCONTEXT}${DLOGO_COLOR} ]"

    GLOGO_COLOR="\e[30;1;34m"
    GP=$(git_prompt)
    [ "$GP" != "" ] && G="${GLOGO_COLOR}[ 🔀 $GP${GLOGO_COLOR}]" || unset G

    PCOLOR="\e[30;1;34m"
    P="${PCOLOR}[ $(pwd) ]"

    S="$( [ "$(id -u)" == "0" ] && echo "#" || echo "$")"

    H="\[\033[01;32m\]\u@\h\[\033[00m\]"
    PS1="$K $D $G \n$P\n$H ${S} "
}



# From https://gist.github.com/michaelneu/943693f46f7aa249fad2e6841cd918d5
COLOR_GIT_CLEAN='\[\033[1;30m\]'
COLOR_GIT_MODIFIED='\[\033[0;33m\]'
COLOR_GIT_STAGED='\[\033[0;36m\]'
COLOR_RESET='\[\033[0m\]'

function git_prompt() {
  # https://gist.github.com/michaelneu/943693f46f7aa249fad2e6841cd918d5?permalink_comment_id=4098489#gistcomment-4098489
  #if [ -e ".git" ]; then   
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    branch_name=$(git symbolic-ref -q HEAD)
    branch_name=${branch_name##refs/heads/}
    branch_name=${branch_name:-HEAD}

    echo -n "→ "

    if [[ $(git status 2> /dev/null | tail -n1) = *"nothing to commit"* ]]; then
      echo -n "$COLOR_GIT_CLEAN$branch_name$COLOR_RESET"
    elif [[ $(git status 2> /dev/null | head -n5) = *"Changes to be committed"* ]]; then
      echo -n "$COLOR_GIT_STAGED$branch_name$COLOR_RESET"
    else
      echo -n "$COLOR_GIT_MODIFIED$branch_name*$COLOR_RESET"
    fi

    echo -n " "
  fi
}