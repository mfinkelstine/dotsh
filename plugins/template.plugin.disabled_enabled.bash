#!/usr/bin/env bash

# adding time to the commands because I'm very interested
# in how long these activities take with more complex builds
# across disparate platforms
command="terraform"

if ! command -v ${command} >/dev/null; then
  printf " ${command} execute not found.\n" >/&2
  printf " Please install ${command} to use aliases.\n" >&2
  return 1
fi

function a{
	printf "${command}"
}
