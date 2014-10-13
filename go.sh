#!/bin/bash
#
# Wrapper for ansible that is more user-friendly
#

set -e # Errors are fatal
#set -x # Debugging

ANSIBLE_ARGS=""
HOSTS=""
HOST_TYPE=""
INVENTORY=""


#
# Print up a syntax diagram and then exit
#
function print_syntax() {
	echo "Syntax: $0 ( -i ./path/to/inventory | --host ip_or_hostname[:ssh_private_key[:ssh_port]] [--host[...]] ) "
	echo "*** "
	echo "*** If 1 or more hosts are specified, the -i parameter is ignored"
	echo "*** "
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

		elif test "$ARG" == "--host"
		then
			HOSTS="${HOSTS} $ARG_NEXT"
			shift

		elif test "$ARG" == "-h"
		then
			print_syntax

		else
			#
			# This was meant for Ansible
			#
			ANSIBLE_ARGS="${ANSIBLE_ARGS} $ARG"

		fi

		#
		# Shifting when there's nothing to shift would be... bad.
		#
		if test "$1"
		then
			shift
		fi

		if test ! "$1"
		then
			break
		fi

	done

	#
	# Loop through our hosts, grab the data from each one, and write it to an inventory file
	#
	if test "$HOSTS"
	then

		if test "$INVENTORY"
		then
			echo "*** "
			echo "*** Sorry, but you can't specify an inventory AND hosts!"
			echo "*** "
			print_syntax
		fi

		INVENTORY="`dirname $0`/inventory/temp"

		echo "*** "
		echo "*** Writing host data to inventory file '$INVENTORY'..."
		echo "*** "
		echo "" > $INVENTORY

		INDEX=0
		for K in ${HOSTS}
		do

			#
			# Default to a production host type, but it will be overriden for Vagrant
			#
			HOST_TYPE="production"

			#
			# Parse our colon-delimited string and grab its hostname, SSH key, etc.
			#
			if [[ "$K" =~ ":" ]]
			then
				HOST=`echo $K | cut -d: -f1`
				SSH_KEY=`echo $K | cut -d: -f2`
				PORT=`echo $K | cut -d: -f3`
				LINE=""

			elif test "$K"
			then
				HOST=$K

			fi

			echo "K: $K" # Debugging
			echo "Parts: $HOST:$SSH_KEY:$PORT" # Debugging
			ANSIBLE_USER="root"

			if test "$HOST" == "vagrant"
			then
				#
				# Special case for a vagrant instance.
				#
				HOST="127.0.0.1"
				PORT="2222"
				SSH_KEY="~/.vagrant.d/insecure_private_key"
				ANSIBLE_USER="vagrant"
				HOST_TYPE="vagrant"

			elif test "$SSH_KEY"
			then
				#echo "FOUND: ssh_key" # Debugging
				PORT="22"

			elif test "$HOST"
			then
				#echo "FOUND: host" # Debugging
				PORT="22"
				SSH_KEY="~/.ssh/id_rsa"

			fi

			LINE="host_${INDEX} ansible_ssh_host=${HOST} ansible_ssh_port=${PORT} ansible_ssh_user=${ANSIBLE_USER} ansible_ssh_private_key_file=${SSH_KEY}"

			#
			# Only write out our host type on the first pass
			#
			if test "$INDEX" == 0
			then
				echo "[${HOST_TYPE}]" >> $INVENTORY
			fi

			#echo "LINE: $LINE" # Debugging
			echo $LINE >> $INVENTORY

			INDEX=$[$INDEX + 1]

		done

		echo ""
		echo "Contents of '${INVENTORY}':"
		cat $INVENTORY
		echo ""

		ANSIBLE_ARGS="${ANSIBLE_ARGS} -i $INVENTORY"

	fi

	if test "$INVENTORY" != "" -a ! -f "$INVENTORY"
	then
		echo "$0: Inventory file ${INVENTORY} not found!"
		print_syntax
	fi

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


#
# Autogenerate SSL keyfiles the first run.
#
SSL_DIR="roles/nginx/files/ssl/"
SSL_CRT="${SSL_DIR}/default.crt"
SSL_KEY="${SSL_DIR}/default.key"
SSL_CSR="${SSL_DIR}/default.csr"
if test ! -f $SSL_KEY
then
	echo "#"
	echo "#"
	echo "# SSL key not found in ${SSL_KEY}, auto-generating a new self-signed key..."

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
# Check for a Splunk deb file.
# 
if test ! -f "splunk.deb"
then
	echo "# "
	echo "# "
	echo "# Unable to find splunk.deb."
	echo "# You can download a copy of Splunk Enterprise from: "
	echo "#		http://www.splunk.com/download "
	echo "# "
	echo "# Once you have a 64-bit .deb file, copy it to this directory. "
	echo "# I recommend that you then symlink \"splunk.deb\" to it. "
	echo "# "
	echo "# Don't worry about cost, you can use Splunk for free for "
	echo "# up to 500 MB of data per day. Splunk is cool like that. :-) "
	echo "# "
	echo "# (And you should totally buy their product for the workplace. It's worth every penny.) "
	echo "# "
	exit 1	
fi


echo "# "
echo "# Running Ansible!"
echo "# "
ansible-playbook $ANSIBLE_ARGS ./playbook.yml


