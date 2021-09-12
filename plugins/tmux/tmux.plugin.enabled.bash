#!/usr/bin/env bash
if ! command -v tmux ; then
  printf " tmux plugin: tmux not found. Please install tmux before using this plugin." >&2
  return 1
fi


