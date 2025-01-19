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

# Check if the number of parameters is not equal to 3
if [ "$#" -ne 3 ]; then
    echo "Error: Missing parameters. Usage: $0 <device> <warn> <crit>"
    exit 3
fi

device="$1"
warn="$2"
crit="$3"

# Extract the temperature value for the specified device
result=$(sensors | grep -A 2 "$device" | grep 'temp1' | awk '{print $2}' | sed 's/+//g' | cut -d'.' -f1)

# Check if we got a valid temperature value
if [ -z "$result" ]; then
    echo "Error: Could not find temperature data for device $device."
    exit 3
fi

message="$device temp is $result°C | $device-temp=$result"

# Compare the temperature with the warning and critical thresholds
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
