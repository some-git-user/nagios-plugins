#!/bin/bash

# Check if the 'sensors' command is available
if ! command -v sensors &>/dev/null; then
    echo "Error: 'sensors' command not found. Please install lm-sensors package."
    exit 3
fi

# Check if the 'bc' command is available
if ! command -v bc &>/dev/null; then
    echo "Error: 'bc' command not found. Please install bc package."
    exit 3
fi

# Check if the number of parameters is not equal to 2
if [ "$#" -ne 2 ]; then
    echo "Error: Missing parameters. Usage: $0 <warn> <crit>"
    exit 3
fi

warn="$1"
crit="$2"

result=$(sensors | grep 'Package id 0:' | awk '{print $4}' | cut -d'+' -f2 | cut -d'.' -f1)

message="CPU temp is $result | cputemp=$result"

if (( $(bc <<< "$result < $warn") )); then
    echo "OK - $message"
    exit 0
elif (( $(bc <<< "$result >= $warn && $result < $crit") )); then
    echo "WARNING - $message"
    exit 1
elif (( $(bc <<< "$result >= $crit") )); then
    echo "CRITICAL - $message"
    exit 2
else
    echo "UNKNOWN - Shouldn't be here: $result"
    exit 3
fi
