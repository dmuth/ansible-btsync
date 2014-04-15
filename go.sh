#!/bin/bash
#
# Wrapper for ansible that is more user-friendly
#

set -e # Errors are fatal
#set -x # Debugging


INVENTORY=""


#
# Print up a syntax diagram and then exit
#
function print_syntax() {
	echo "Syntax: $0 -i ./path/to/inventory"
	exit 1;
}


DIR="roles/munin-nginx/templates"
if test ! -f "${DIR}/htpasswd"
then
	echo "You need to create ${DIR}/htpasswd. "
	echo "You can do this with the Apache htpasswd utility!"
	exit 1
fi

#
# Parse our arguments
#
while true
do

	if test ! "$1"
	then
		break
	fi

	if test "$1" == "-i"
	then
		INVENTORY=$2
		shift
	fi

	shift
done

if test ! "$INVENTORY"
then
	print_syntax
fi

ansible-playbook ./playbook.yml -i ${INVENTORY}


