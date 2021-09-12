#!/usr/bin/env bash


#about-alias 'docker abbreviations'
alias dk='docker' 	      			# docker binary command
alias dklc='docker ps -l' 			# docker list last container 
alias dklcid='docker ps -l -q'		# docker list last contaner ID
alias dklcip='docker inspect -f "{{.NetworkSetings.IPAddress }}" $(docker ps -l -q)' # get IP of last docker container

alias dkps='docker ps' 				# docker list running containers
alias dkpsa='docker ps -a'			# List all Docker containers
alias dki='docker images' 			# List Docker Images
