#!/bin/bash
#controla la version de sshd
for each_entry in $(type -a sshd | awk '{print $NF}' | uniq); do
  version_string=$(strings "$each_entry" | grep -o "OpenSSH_[0-9]\+\.[0-9]\+p[0-9]\+" | uniq)
  if [ -n "$version_string" ]; then
    version=$(echo "$version_string" | sed -E 's/OpenSSH_([0-9]+\.[0-9]+)p[0-9]+/\1/')
    major_version=$(echo $version | cut -d '.' -f 1)
    minor_version=$(echo $version | cut -d '.' -f 2)
    
    if [ "$major_version" -lt 4 ] || ([ "$major_version" -eq 4 ] && [ "$minor_version" -lt 4 ]); then
      status="YES (Unless patched for CVE-2006-5051 and CVE-2008-4109)"
    elif ([ "$major_version" -eq 4 ] && [ "$minor_version" -ge 4 ]) || ([ "$major_version" -ge 5 ] && [ "$major_version" -lt 8 ]) || ([ "$major_version" -eq 8 ] && [ "$minor_version" -lt 5 ]); then
      status="NO"
    elif ([ "$major_version" -eq 8 ] && [ "$minor_version" -ge 5 ]) || ([ "$major_version" -eq 9 ] && [ "$minor_version" -le 7 ]); then
      status="YES"
    else
      status="Unknown"
    fi

    echo "Found OpenSSH version: $version in $each_entry"
    echo "Vulnerability Status: $status"
    if [ "$status" == "YES" ]; then
      echo "Patch Immediately to OpenSSH 9.8/9.8p1"
    fi
  else
    echo "No match found for $each_entry"
  fi
done
