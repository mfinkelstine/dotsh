#!/usr/bin/env bash

source ${DOTLIB}/system.functions.sh

if ! command -v docker >/dev/null; then
  printf " docker plugin not found.\n" >/&2
  printf " Please install docker to use this plugin.\n" >&2
  return 1
fi

#if is_enabled 
#about-alias 'docker abbreviations'
alias dk='docker' 	      			# docker binary command
alias dklc='docker ps -l' 			# docker list last container 
alias dklcid='docker ps -l -q'		# docker list last contaner ID
alias dklcip='docker inspect -f "{{.NetworkSetings.IPAddress }}" $(docker ps -l -q)' # get IP of last docker container

alias dkps='docker ps' 				# docker list running containers
alias dkpsa='docker ps -a'			# List all Docker containers
alias dki='docker images' 			# List Docker Images


function dexec() {
  local docker_name=${1}

  docker exec -it flask bash
}

function drun() {
  local container_name=${1:-null}
  local docker_name=${2:-null}

  if [ ${container_name} == "null"]; then
    logger "warn" "You most provide a container name to run it"
    return
  fi
  if [ ${docker_name} == "null" ]; then
    docker run -d flask-python
  fi

}