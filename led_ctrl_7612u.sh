#!/bin/bash

# Purpose:
#
# Supports:

SCRIPT_NAME="led_ctrl_7612u.sh"
SCRIPT_VERSION="20221021"

# check to ensure sudo was used
if [[ $EUID -ne 0 ]]
then
	echo "You must run this script with superuser (root) privileges."
	echo "Try: \"sudo ./${SCRIPT_NAME}\""
	exit 1
fi



exit 0
