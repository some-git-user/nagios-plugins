#!/bin/bash

# Check if a device is provided as a parameter
if [ -z "$1" ]; then
    echo "Usage: $0 <device>"
    exit 3
fi

device=$1

# Check for the RAID array state using mdadm
mdadm_output=$(mdadm --detail "$device")
mdadm_state=$(echo "$mdadm_output" | grep -E 'State : ' | awk -F': ' '{print $2}' | tr -d '[:space:]')
mdadm_ceck_status=$(echo "$mdadm_output" | grep -E 'Check Status : ' | awk -F': ' '{print $2}')

# Check if the RAID array is in recovery using /proc/mdstat
recovery_status=$(cat /proc/mdstat | grep "$device" | grep -oP 'recovery\([^\)]+\)')

# Handle various RAID states
case "$mdadm_state" in
    "clean" | "active")
        # Healthy states
        echo "OK - RAID array is healthy (State: $mdadm_state)"
        exit 0
        ;;
    "resync" | "resyncing")
        # Degraded states
        echo "WARNING - RAID array is in resync (State: $mdadm_state)"
        exit 1
        ;;
    "active,checking" | "clean,checking")
        # Degraded states
        echo "WARNING - RAID array is in an checking state (State: $mdadm_state) $mdadm_ceck_status"
        exit 1
        ;;
    "degraded" | "failed")
        # Critical states
        echo "CRITICAL - RAID array is in a critical state (State: $mdadm_state)"
        exit 2
        ;;
    *)
        # Other possible states (or unknown states)
        echo "UNKNOWN - RAID array is in an unknown state: $mdadm_output"
        exit 3
        ;;
esac

# Check for RAID recovery status in /proc/mdstat if the array isn't in a clean or active state
if [ ! -z "$recovery_status" ]; then
    echo "WARNING - RAID array is in recovery: $recovery_status"
    exit 1
fi

# If no matching state is found, return UNKNOWN
echo "UNKNOWN - RAID array state is not recognized: $mdadm_output"
exit 3
