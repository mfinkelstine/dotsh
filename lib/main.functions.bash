#!/usr/bin/env bash

export MBP_LIB="${MBP_PATH}/lib"
printf "MBP_PATH IS: %s " "${MBP_PATH}"
source "${MBP_LIB}/logger.functions.bash"
source "${MBP_LIB}/system.functions.bash"
# shellcheck source=src/debug.bash

# shellcheck source=src/decorate.bash
source "${MBP_PATH}/src/decorate.bash"

