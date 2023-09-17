#!/bin/bash

PLACED_DIRECTORY="/home/ivysola/nextclond_backup/borg/"
MOUNTPOINT="/yadisk/nx_backups/"
ARCHIVE_NAME="nx_cloud.backup.zip"
TEMP_FOLDER="/tmp/nxcloud_backup_transit/"

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

if ! [ -d "$PLACED_DIRECTORY" ]; then
    echo "The placed directory does not exist."
    exit 1
fi

if ! [ -d "$MOUNTPOINT" ]; then
    echo "The mountpoint must be an existing directory"
    exit 1
fi

if [ -z "$(ls -A "$PLACED_DIRECTORY/")" ]; then
    echo "The source directory is empty which is not allowed."
    exit 1
fi

if ! grep -q "$MOUNTPOINT" /etc/fstab; then
    echo "Could not find the mountpoint in the fstab file. Did you add it there?"
    exit 1
fi

if [ -f "$PLACED_DIRECTORY/lock.roster" ]; then
    echo "Cannot run the script as the backup archive is currently changed. Please try again later."
    exit 1
fi

if [ -f "$PLACED_DIRECTORY/aio-lockfile" ]; then
    echo "Not continuing because aio-lockfile already exists."
    exit 1
fi

touch "$PLACED_DIRECTORY/aio-lockfile"

if ! [ -d "$TEMP_FOLDER" ]; then
    mkdir $TEMP_FOLDER
fi



zip -r "${TEMP_FOLDER}${ARCHIVE_NAME}"
echo "Success create zip archive."
chmod 664 "${TEMP_FOLDER}${ARCHIVE_NAME}"
echo "Success fixed pex on zip archive."
cp -rf "${TEMP_FOLDER}${ARCHIVE_NAME}" $MOUNTPOINT
echo "Success fixed pex on zip archive."
rm "${TEMP_FOLDER}${ARCHIVE_NAME}"

rm "$PLACED_DIRECTORY/aio-lockfile"
