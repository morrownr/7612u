#!/bin/bash

OPTIONS_FILE="mt76_usb.conf"

SCRIPT_NAME="install-options.sh"

if [[ $EUID -ne 0 ]]; then
	echo "You must run this script with superuser (root) privileges."
	echo "Try: \"sudo ./${SCRIPT_NAME}\""
	exit 1
fi

echo "Copying ${OPTIONS_FILE} to: /etc/modprobe.d"
cp -r ${OPTIONS_FILE} /etc/modprobe.d

if [[ "$RESULT" != "0" ]]; then
	echo "An error occurred : ${RESULT}"
	exit $RESULT
else
	echo "${OPTIONS_FILE} was installed successfully."
	exit 0
fi
