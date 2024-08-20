#!/bin/bash

THRESHOLD=80

# If no arguments are passed, print the instruction and terminate the script
if [ "$#" -eq 0 ]; then
    echo "Please mention all the disks you need to check."
    echo "Usage: $0 /path/to/disk1 /path/to/disk2 ..."
    echo "Example: $0 / /home /var"
    exit 1
fi

# Email for alert messages
echo "Write your email: user@example.com"
read EMAIL

# Path to user's log file
echo "Specify the path to the log file (e.g., /path/to/log):"
read LOG_FILE

# Checking if the specified directory exists
DIR=$(dirname "$LOG_FILE")

if [ ! -d "$DIR" ]; then
    echo "The directory $DIR does not exist."
    echo "Do you want to create it? (Y/N)"
    read CREATE_DIR

    if [ "$CREATE_DIR" == "Y" ] || [ "$CREATE_DIR" == "y" ]; then
        mkdir -p "$DIR"
        if [ $? -eq 0 ]; then
            echo "Directory $DIR created successfully."
        else
            echo "Failed to create directory $DIR. Please specify a different path."
            exit 1
        fi
    else
        echo "Please specify a different path for the log file."
        exit 1
    fi
fi

# Array of passed arguments
DISKS=("$@")

# Extract disk usage from each disk in the array
printf "%-15s %-10s\n" "Disk" "Usage"
printf "%-15s %-10s\n" "----" "-----"
for DISK in "${DISKS[@]}"; do
    # Получаем строку с информацией о диске
    DISK_INFO=$(df "$DISK" | grep -w "$DISK")
    
    if [ -z "$DISK_INFO" ]; then
        echo "Failed to retrieve disk information for $DISK."
        continue
    fi
    
    USAGE=$(echo "$DISK_INFO" | awk '{ print $5 }' | sed 's/%//g')

    # Checking that the USAGE variable is not empty
    if [ -z "$USAGE" ]; then
        echo "Failed to retrieve disk usage for $DISK."
        continue
    fi

    printf "%-15s %-10s\n" "$DISK" "$USAGE%"

    if [ "$USAGE" -gt "$THRESHOLD" ]; then
        tput setaf 1; echo "Disk usage on $DISK is above threshold: $USAGE%"; tput sgr0
        echo "Disk usage on $DISK is above threshold: $USAGE%" | mail -s "Disk Space Alert" $EMAIL
    else
        tput setaf 2; echo "Disk usage on $DISK is within limits: $USAGE%"; tput sgr0
    fi

    echo "$(date "+%H:%M %d/%m/%Y"): Disk usage on $DISK is $USAGE%" >> $LOG_FILE
done
