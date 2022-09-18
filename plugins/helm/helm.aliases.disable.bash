#!/usr/bin/env bash

#source $DOTSH

command_exec="helm"

if ! command -v ${command_exec} >/dev/null; then
  printf " ${command_exec} execute not found.\n" >/&2
  printf " Please install ${command_exec} to use aliases.\n" >&2
  return 1
fi
