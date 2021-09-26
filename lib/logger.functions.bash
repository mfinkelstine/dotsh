#!/usr/bin/env bash

_LOGGER_NAME="bash-logger"
_LOGGER_VERSION="v0.0.1"
_LOGGER_DATE="25/09/2021"

#--------------------------------------------------------------------------------------------------
# Configurables

export LOGFILE=~/bash-logger.log
export LOG_FORMAT='%DATE %PID [%LEVEL] %MESSAGE'    
export LOG_DATE_FORMAT='+%F %T %Z'                  # Eg: 2014-09-07 21:51:57 EST
export LOG_COLOR_DEBUG="\033[0;37m"                 # Gray
export LOG_COLOR_INFO="\033[0m"                     # White
export LOG_COLOR_NOTICE="\033[1;32m"                # Green
export LOG_COLOR_WARNING="\033[1;33m"               # Yellow
export LOG_COLOR_ERROR="\033[1;31m"                 # Red
export LOG_COLOR_CRITICAL="\033[44m"                # Blue Background
export LOG_COLOR_ALERT="\033[43m"                   # Yellow Background
export LOG_COLOR_EMERGENCY="\033[41m"               # Red Background
export RESET_COLOR="\033[0m"




function logger(){
    local logLevel="$1"
    local logData="$2"
    local pid=$$
    local date



}