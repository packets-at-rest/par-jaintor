#!/usr/bin/env bash

## Janitor v 0.2 (FreeBSD focused)

# Immediately exit upon shell error
set -e

path_to_flock=$(which flock)
if ! [[ -x "$path_to_flock" ]] ; then
  echo "Error: Can not locate flock on the PATH"
  exit 1
fi

# Set lock file details
scriptname=$(basename $0)
lock="/var/run/${scriptname}"

# Lock the process, or exit if already running
exec 200>$lock
flock -n 200 || exit 1

# Write the PID to the lock file
pid=$$
echo $pid 1>&200

# Define the location of the applications
DF="/bin/df"
AWK="/usr/bin/awk"
SED="/usr/bin/sed"
FIND="/usr/bin/find"

# Define the directory to check
DIR="/opt/filed-capture"

# Define constants
Minimum=100   # Minimum space below which files will be deleted (MB)
DeleteTo=200  # Delete files until this value is reached (MB)
NumtoDel=25  # Number of files to delete between each free disk space check

# Set shell such that empty file listing will return null
shopt -s nullglob

# Check if free space is less than the minimum specified
FreeSpace=$($DF -m $DIR | $AWK '{print $4}' | $SED "1d")
if [ $FreeSpace -lt $Minimum ]; then
  # Free space has dropped below minimum value, delete files until DeleteTo space is free
  while [ $FreeSpace -lt $DeleteTo ]; do
    # Check if any pictures remain in the directory, otherwise break out of the delete loop
    if test -z "$($FIND $DIR -maxdepth 1 -name '*.jpg' -print -quit)"; then
      break
    fi
    # Delete files until NumtoDel has been reached, or no more files exist
    FileCount=0;
    for FileName in $DIR/*.jpg; do
      rm $FileName
      FileCount=$((FileCount+1))
      # Check if number of files to delete has been reached
      if [ $FileCount -ge $NumtoDel ]; then
        break
      fi
    done
    # Check if free space is less than the minimum specified
    FreeSpace=$($DF -m $DIR | $AWK '{print $4}' | sed "1d")
  done
fi
