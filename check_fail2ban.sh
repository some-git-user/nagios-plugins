#!/bin/bash

# Check if the 'fail2ban-client' command is available
if ! command -v fail2ban-client &>/dev/null; then
    echo "Error: 'fail2ban-client' command not found. Please install fail2ban package."
    exit 3
fi

# Check if the 'ipcalc' command is available
if ! command -v ipcalc &>/dev/null; then
    echo "Error: 'ipcalc' command not found. Please install ipcalc package."
    exit 3
fi

# Optional parameter for whitelist subnet
whitelist_subnet=$1

# Get banned IPs
banned_ips=$(fail2ban-client banned)

# Check if there are banned IPs
has_banned_ips=false
for jail in $banned_ips; do
  jail=${jail#\[}
  jail=${jail%\]}
  for key in "${!jail[@]}"; do
    if [ "${jail[$key]}" != "[]" ]; then
      has_banned_ips=true
      break
    fi
  done
  if $has_banned_ips; then
    break
  fi
done

if ! $has_banned_ips; then
  echo "OK - No banned IPs"
  exit 0
fi

# Function to check if an IP is within a subnet
is_in_subnet() {
  local ip=$1
  local subnet=$2
  local subnet_ip=$(echo "$subnet" | cut -d '/' -f 1)
  local subnet_cidr=$(echo "$subnet" | cut -d '/' -f 2)
  local ip_cidr=$(ipcalc -c -n "$ip" | cut -d '=' -f 2)
  if [ "$ip_cidr" == "$subnet_cidr" ]; then
    local ip_network=$(ipcalc -n "$ip" | cut -d '=' -f 2)
    local subnet_network=$(ipcalc -n "$subnet_ip" | cut -d '=' -f 2)
    if [ "$ip_network" == "$subnet_network" ]; then
      return 0
    fi
  fi
  return 1
}

# Check banned IPs against the provided subnet
for jail in $banned_ips; do
  jail=${jail#\[}
  jail=${jail%\]}
  for key in "${!jail[@]}"; do
    if [ "${jail[$key]}" != "[]" ]; then
      for ip in "${jail[$key]}"; do
        if is_in_subnet "$ip" "$whitelist_subnet"; then
          echo "Banned IP $ip is within subnet $whitelist_subnet"
          exit 2
        fi
      done
    fi
  done
done

# All banned IPs are not in the whitelist subnet
echo "OK - All banned IPs are not in the whitelist subnet"
echo "Banned IPs: $banned_ips"
exit 0