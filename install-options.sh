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
echo "${OPTIONS_FILE} was installed successfully."

read -p "Do you want edit the options file? [y/n] " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    nano /etc/modprobe.d/${OPTIONS_FILE}
fi

read -p "Are you ready to reboot? [y/n] " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    reboot
fi

exit 0
