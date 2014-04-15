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


#
# I can't keep my real password file in revision control, for obvious reasons.
# 
DIR="roles/nginx/templates"
if test ! -f "${DIR}/htpasswd"
then
	echo "You need to create ${DIR}/htpasswd. "
	echo "You can do this with the Apache htpasswd utility!"
	exit 1
fi


#
# All of this insanity is because I can't go through $@ and use shift, 
# as I need to pass those arguments onto ansible.
# 
# I learned *that* the hard way when trying to use -vvvv
#
INVENTORY=""
INVENTORY_FOUND=""
for I in $@
do

	if test "$INVENTORY_FOUND"
	then
		INVENTORY=$I
	fi

	if test "$I" == "-i"
	then
		INVENTORY_FOUND=1
	fi

	if test "$INVENTORY"
	then
		break
	fi

done

if test ! "$INVENTORY"
then
	print_syntax
fi

ansible-playbook $@ ./playbook.yml



