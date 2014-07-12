#!/bin/bash
#
# Wrapper for ansible that is more user-friendly
#

set -e # Errors are fatal
#set -x # Debugging

ANSIBLE_ARGS=""
HOSTS=""
INVENTORY=""


#
# Print up a syntax diagram and then exit
#
function print_syntax() {
	echo "Syntax: $0 -i ./path/to/inventory"
	exit 1;
}


#
# Loop through all of our args and pass them
#
function parse_args() {

	while true
	do
		#echo "REMAINING: $*" # Debugging

		ARG=$1
		ARG_NEXT=$2

		if test "$ARG" == "-i"
		then
			INVENTORY=$ARG_NEXT
			ANSIBLE_ARGS="${ANSIBLE_ARGS} -i $ARG_NEXT"
			shift

		else
			ANSIBLE_ARGS="${ANSIBLE_ARGS} $ARG"

		fi

		shift

		if test ! "$1"
		then
			break
		fi

	done

	if test "$INVENTORY" != "" -a ! -f "$INVENTORY"
	then
		echo "$0: Inventory file ${INVENTORY} not found!"
		print_syntax
	fi

	return

} # End of parse_args()

parse_args $@
#echo "PARSED VARIABLES: $INVENTORY, $HOSTS, $ANSIBLE_ARGS" # Debugging


#
# I can't keep my real password file in revision control, for obvious reasons.
# 
DIR="roles/nginx/templates"
HTPASSWD="${DIR}/htpasswd"
if test ! -f "${HTPASSWD}"
then
	echo "#"
	echo "# Missing password file ${HTPASSWD}!"
	echo "# Creating one automatically"
	echo "#"

	PASS="$(( ( RANDOM % 1000 ) + 1))$(( ( RANDOM % 1000 ) + 1))$(( ( RANDOM % 1000 ) + 1))"

	htpasswd -bc ${HTPASSWD} munin ${PASS}

	echo "#"
	echo "# htpasswd file created"
	echo "# Login: munin Password: ${PASS}"
	echo "#"
	echo "# This is for viewining munin stats at https://SERVER_IP:8889/munin/"
	echo "# Please make note of the 'https', port number, and trailing slash."
	echo "#"

fi


SSL_DIR="roles/nginx/files/ssl/"
SSL_CRT="${SSL_DIR}/default.crt"
SSL_KEY="${SSL_DIR}/default.key"
SSL_CSR="${SSL_DIR}/default.csr"
if test ! -f $SSL_KEY
then
	echo "SSL key not found in ${SSL_KEY}, auto-generating a new self-signed key..."

	echo "#"
	echo "#"
	echo "# About to generate private key"
	echo "#"
	echo "#"
	openssl genrsa -des3 -passout pass:12345 -out ${SSL_KEY} 2048

	echo "#"
	echo "#"
	echo "# About to create certificate signing request"
	echo "# For these questions, if the key is not being used by members "
	echo "# of the public, you can just mash the <enter> key..."
	echo "#"
	echo "#"
	openssl req -new -passin pass:12345 -key ${SSL_KEY} -out ${SSL_CSR}

	#
	# Remove the passphrase from the key
	#
	cp ${SSL_KEY} ${SSL_KEY}.orig
	openssl rsa -passin pass:12345 -in ${SSL_KEY}.orig -out ${SSL_KEY}
	rm -f ${SSL_KEY}.orig

	echo "#"
	echo "#"
	echo "# Creating the self-signed certificate."
	echo "#"
	echo "#"
	openssl x509 -req -days 365 -in ${SSL_CSR} -signkey ${SSL_KEY} -out ${SSL_CRT}

	echo "#"
	echo "#"
	echo "# All done!  Here are your files:"
	echo "# Private key: ${SSL_KEY}"
	echo "# Certificate: ${SSL_CRT}"
	echo "# Certificate signing request: ${SSL_CSR} (In case you want this signed later)"
	echo "#"
	echo "#"

fi

ansible-playbook $ANSIBLE_ARGS ./playbook.yml


