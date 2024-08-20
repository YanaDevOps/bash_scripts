#!/bin/bash
# Backup script

SRC_DIR=$(realpath "$1")
DEST_DIR=$(realpath "$2")
DATE=$(date +%Y-%m-%d-%H-%M)

# Checking if the user passed the arguments
if [ -z "$SRC_DIR" ] || [ -z "$DEST_DIR" ]; then
	echo "Please, set the source and destination dirs paths"
	exit 1
fi

# Checking if the source directory exists
if [ ! -d "$SRC_DIR" ]; then
	echo "This directory doesn't excist."
	echo "Choose another directory"
	exit 1
fi

# Checking if the destination directory exists
if [ ! -d "$DEST_DIR" ]; then
	echo "This directory doesn't excist."
	echo "Create a directory? Y(yes)/N(no)?"
	read DIR_ANSW
	if [ $DIR_ANSW == "Y" ]; then
		mkdir -p "$DEST_DIR"
	else
		echo "Choose another directory"
		exit 1
	fi
fi

#Archive a source directory and copy it to the destination directory
tar -czf $DEST_DIR/backup_$DATE.tar.gz $SRC_DIR
echo "Backup completed successfully!"
