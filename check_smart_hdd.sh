#!/bin/bash

# Check if a drive is provided as a parameter
if [ -z "$1" ]; then
    echo "Usage: $0 <drive>"
    exit 3
fi

drive=$1

# Run the SMART check on the specified drive
result=$(smartctl -H "$drive" | grep "SMART overall-health self-assessment test result: PASSED")

# Check the result and respond accordingly
if [ "$result" = "SMART overall-health self-assessment test result: PASSED" ]; then
    echo "OK - SMART check passed"
    echo $result
    exit 0
else
    echo "CRITICAL - SMART state critical"
    echo $result
    exit 2
fi

echo "UNKNOWN - Shouldn't be here"
exit 3
