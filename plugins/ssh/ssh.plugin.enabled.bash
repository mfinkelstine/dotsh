#!/usr/bin/env bash

function ssh {
  /usr/bin/ssh $* || if [ "$?" -eq "255" ] ; then
    line=$(/usr/bin/ssh $* 2>&1 |grep Offending|cut -f2 -d:)
    sed -i -e "${line}d" ~/.ssh/known_hosts
    echo "Host key changed. Wiping from ~/.ssh/known_hosts." >&2
    /usr/bin/ssh $*
  fi
}

function start_agent {
	echo -n "Initialising new SSH agent..."
	/usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
	echo succeeded
	chmod 600 "${SSH_ENV}"
	. "${SSH_ENV}" > /dev/null
	/usr/bin/ssh-add; /usr/bin/ssh-add ~/.ssh/id_github_rsa
}