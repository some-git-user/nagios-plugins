#!/bin/bash
if [ -e /var/run/reboot-required.pkgs ]
then
        echo  "CRITICAL - System restart required"
        exit 2
else
        echo "OK - No restart required"
        exit 0
fi
        echo "UNKNOWN - Shouldn't be here"
        exit 3