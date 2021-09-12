#!/usr/bin/env bash

source ${DOTSH}/lib

if ! command -v docker >/dev/null; then
  printf " docker plugin not found.\n" >/&2
  printf " Please install docker to use this plugin.\n" >&2
  return 1
fi

#if is_enabled 
