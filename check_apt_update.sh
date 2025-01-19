#!/bin/bash

result=$(apt update 2>/dev/null | grep "All packages are up to date.")

if [ "$result" = "All packages are up to date." ]
then
    echo "OK - APT up to date"
        exit 0
fi

result=$(apt update 2>/dev/null | grep "can be upgraded" | cut -d '.' -f 1)
long_output=$(apt list --upgradable 2>/dev/null | grep -v "Listing...")
security_updates=$(echo $long_output | grep -o "security" | grep -c .)

if [ ! -z "$result" ] && [ "$security_updates" -ne "0" ]
then
    echo "CRITICAL - $result ($security_updates) security packages"
    echo $long_output
        exit 2
elif [ ! -z "$result" ]
then
    echo "WARNING - $result"
    echo $long_output
        exit 1
fi
    echo "UNKNOWN - Shouldn't be here"
        exit 3
