#!/bin/bash

# Check if the 'jq' command is available
if ! command -v jq &>/dev/null; then
    echo "Error: 'jq' command not found. Please install jq package."
    exit 3
fi

# Check if the 'curl' command is available
if ! command -v curl &>/dev/null; then
    echo "Error: 'curl' command not found. Please install curl package."
    exit 3
fi

if [ -z "$1" ]; then
    echo "Usage: $0 <nextcloud_url> e.g. https://nextcloud.com"
    exit 3
fi

nextcloud_url=$1
nextcloud_newest_version=$(curl -s https://nextcloud.com/changelog/ | awk '/Version / {print $2}' | head -n 1)
nextcloud_current_version=$(curl -s "$nextcloud_url/status.php" | jq -r '.versionstring')

if [ "$nextcloud_current_version" != "$nextcloud_newest_version" ]; then
    echo "CRITICAL - Nextcloud is not up to date. Current version: $nextcloud_current_version. Newest version: $nextcloud_newest_version"
    exit 2
else
    echo "OK - Nextcloud is up to date. Current version: $nextcloud_current_version. Newest version: $nextcloud_newest_version"
    exit 0
fi