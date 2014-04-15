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



