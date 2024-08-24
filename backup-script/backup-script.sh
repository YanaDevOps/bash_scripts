#!/bin/bash

# Get the absolute paths of the source and destination directories
SRC_DIR=$(realpath "$1" | sed 's:/*$::')  # Remove the trailing slash if there is one
DATE=$(date +%Y-%m-%d-%H-%M)
LOGROTATE_PATH="/etc/logrotate.d/"  # Path to the logrotate configuration directory
LOG_NAME=$(basename "$SRC_DIR" .log)  # Get the base name of the log file (without extension)

# Check if the path is a file
is_file () {
    local PATH=$1

    if [ -f "$PATH" ]; then
        return 0
    else
        return 1
    fi
}

# Check if the directory exists
is_directory () {
    local PATH=$1

    if [ -d "$PATH" ]; then
        return 0
    else
        return 1
    fi
}

create_directory () {
    local NEW_DIR=$1

    mkdir -p "$NEW_DIR"
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Check directory permissions
check_permissions () {
    local DIR=$1
    local PERM

    PERM=$(stat -c "%a" "$DIR")
    if [[ "$PERM" == "777" || "$PERM" == "775" ]]; then
        return 1
    else
        return 0
    fi
}

# Fix directory permissions
fix_permissions () {
    local DIR=$1

    sudo chmod 755 "$DIR"
    if [ $? -eq 0 ]; then
        echo "Permissions for $DIR have been fixed to 755."
        return 0
    else
        echo "Failed to fix permissions for $DIR."
        return 1
    fi
}

# Function to archive the source directory and copy it to the destination directory
archive_targz () {
    local SRC=$1
    local DEST=$2

    # Create a tar.gz archive of the source directory
    tar -czf "$DEST/backup_$DATE.tar.gz" "$SRC"
}

# Function to determine the user's Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release  # Source the os-release file to get distribution info
        echo "$ID"
        return 0
    else
        echo "Cannot determine your Linux distribution."
        return 1
    fi
}

# Function to configure log rotation
log_rotate () {
    local ROTATE_TIME=$1
    local COPY_AMOUNT=$2
    local COMPRESS=$3
    local PERMISSIONS=$4
    local USER=$5
    local GROUP=$6
    local SU_USER=$7
    local SU_GROUP=$8

    # Generate the correct logrotate configuration file
    CONFIG_CONTENT="$SRC_DIR {
        su $SU_USER $SU_GROUP
        $ROTATE_TIME
        missingok
        rotate $COPY_AMOUNT
        $COMPRESS
        delaycompress
        notifempty
        create $PERMISSIONS $USER $GROUP
    }"

    # Write the configuration to a file
    echo "$CONFIG_CONTENT" > "$LOGROTATE_PATH/$LOG_NAME"

    # Verify that the logrotate configuration was created successfully
    if [ -f "$LOGROTATE_PATH/$LOG_NAME" ]; then
        # Запуск logrotate с новым файлом конфигурации и фильтрация вывода
        if logrotate -v "$LOGROTATE_PATH/$LOG_NAME" 2>&1 | grep -E "Handling|rotating pattern:|considering log" | head -n 5; then
            echo ""
            echo "Logrotate configuration for $LOG_NAME has been successfully created and tested."
            echo ""
            return 0
        else
            echo ""
            echo "Logrotate configuration for $LOG_NAME was created, but logrotate failed to execute correctly."
            echo ""
            return 1
        fi
    else
        echo ""
        echo "Failed to create logrotate configuration file for $LOG_NAME."
        echo ""
        return 1
    fi
}

logrotate_install () {
    # Check if logrotate is installed, and install it if necessary
    if ! command -v logrotate &>/dev/null; then
        DISTR=$(detect_distro)  # Detect the Linux distribution

        # Install logrotate based on the detected distribution
        if [ "$DISTR" == "ubuntu" ] || [ "$DISTR" == "debian" ]; then
            sudo apt install logrotate -y > /dev/null 2>&1

            if command -v logrotate &>/dev/null; then
                return 0
            else
                return 1
            fi
        elif [ "$DISTR" == "centos" ] || [ "$DISTR" == "rhel" ] || [ "$DISTR" == "fedora" ]; then
            sudo yum install logrotate -y > /dev/null 2>&1

            if command -v logrotate &>/dev/null; then
                return 0
            else
                return 1
            fi
        fi
    fi
    return 0  # If logrotate is already installed
}

#############################################################
################### Start of the script #####################
#############################################################

# Check if the user passed the necessary argument (source dir or log file)
if [ -z "$SRC_DIR" ]; then
    echo "Please, set the source dir/file.log paths"
    echo "Example: ./$0 /source/path"
    echo "Example: ./$0 /source/path/file.log"
    exit 1
fi

# Additional check for empty variables after the dir_existence function call
if [ -z "$SRC_DIR" ]; then
    echo "Error: Source directory path is empty. Please provide valid path."
    exit 1
fi

if is_file "$SRC_DIR"; then
    echo "$SRC_DIR is a valid file. Proceeding..."
elif is_directory "$SRC_DIR"; then
    echo "$SRC_DIR is a valid directory. Proceeding..."
else
    echo ""
    echo "The directory $SRC_DIR does not exist."
    echo "Do you want to create it? (Y/N)"
    echo ""
    read -p "> " CREATE_DIR

    case "$CREATE_DIR" in
        Y|y)
            if create_directory "$SRC_DIR"; then
                echo "Directory $SRC_DIR created successfully."
            else
                echo "Failed to create directory $SRC_DIR."
                exit 1
            fi
            ;;
        N|n)
            echo "Please specify a different path for the directory."
            read -p "> " NEW_PATH
            SRC_DIR=$(realpath "$NEW_PATH")

            if ! is_directory "$SRC_DIR"; then
                if create_directory "$SRC_DIR"; then
                    echo "Directory $SRC_DIR created successfully."
                else
                    echo "Failed to create directory $SRC_DIR."
                    exit 1
                fi
            else
                echo "$SRC_DIR is a valid directory. Proceeding..."
            fi
            ;;
        *)
            echo "Invalid input. Please enter Y (yes) or N (no)."
            exit 1
            ;;
    esac
fi

# Ask the user if they want to set up log rotation for their log file
echo ""
echo "Would you like to set up a Logrotate for your logfile? Y/N"
read -p "> " ANSW
echo ""

# Check and fix permissions if necessary
if ! check_permissions "$(dirname "$SRC_DIR")"; then
    echo "Insecure permissions detected on the parent directory of $SRC_DIR."
    echo "Would you like to fix them automatically? (Y/N)"
    read -p "> " FIX_PERM

    case "$FIX_PERM" in
        Y|y)
            if fix_permissions "$(dirname "$SRC_DIR")"; then
                echo "Permissions have been fixed."
            else
                echo "Failed to fix permissions. Please check manually."
                exit 1
            fi
            ;;
        N|n)
            echo "Log rotation may fail due to insecure permissions."
            ;;
        *)
            echo "Invalid input. Please enter Y (yes) or N (no)."
            exit 1
            ;;
    esac
fi

if [[ "$ANSW" == "Y" || "$ANSW" == "y" ]]; then
    echo "====================================================="
    echo "How often to do the rotation?"
    echo "====================================================="
    echo "1 - daily"
    echo "2 - weekly"
    echo "3 - monthly"
    echo "4 - yearly"
    echo "5 - hourly"
    echo "6 - size [custom size]"
    read -p "> " ROTATE_ANSW

    case $ROTATE_ANSW in
        1) ROTATE_ANSW="daily" ;;
        2) ROTATE_ANSW="weekly" ;;
        3) ROTATE_ANSW="monthly" ;;
        4) ROTATE_ANSW="yearly" ;;
        5) ROTATE_ANSW="hourly" ;;
        6) 
            echo "Enter custom size (e.g., 100M, 1G):"
            read CUSTOM_SIZE
            echo ""
            ROTATE_ANSW="size $CUSTOM_SIZE"
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac

    # Get additional logrotate settings from the user
    echo "====================================================="
    echo "How many log copies would you like to keep? e.g 4"
    echo "====================================================="
    read -p "> " COPY_ANSW

    echo ""
    echo "====================================================="
    echo "Would you like to compress? Y/N"
    echo "====================================================="
    read -p "> " COMPRESS_ANSW

    if [ "$COMPRESS_ANSW" == "Y" ] || [ "$COMPRESS_ANSW" == "y" ]; then
        COMPRESS_ANSW="compress"
    else
        COMPRESS_ANSW=""
    fi

    echo ""
    echo "============================================================================"
    echo "What permissions should have your Logrotate file? e.g. 640"
    echo "============================================================================"
    read -p "> " PERM_ANSW

    echo ""
    echo "============================================================================"
    echo "Which user will have the specified access to the file? e.g. root"
    echo "============================================================================"
    read -p "> " USER_ANSW

    echo ""
    echo "============================================================================"
    echo "Which group will have the specified access to the file? e.g. adm"
    echo "============================================================================"
    read -p "> " GROUP_ANSW

    echo ""
    echo "============================================================================"
    echo "On behalf of which user will all log rotation actions be performed? e.g. root"
    echo "============================================================================"
    read -p "> " SU_USER

    echo ""
    echo "============================================================================"
    echo "On behalf of which group will all log rotation actions be performed? e.g. adm"
    echo "============================================================================"
    read -p "> " SU_GROUP  

    # Set up log rotation with the provided settings

    if command -v logrotate &>/dev/null; then
        if RESULT=$(log_rotate "$ROTATE_ANSW" "$COPY_ANSW" "$COMPRESS_ANSW" "$PERM_ANSW" "$USER_ANSW" "$GROUP_ANSW" "$SU_USER" "$SU_GROUP"); then
            echo "Logrotate for $LOG_NAME has been successfully configured!"
            echo ""
            echo "************************************************************"
            echo "$RESULT"
            echo "************************************************************"
            echo ""
        else
            echo "Logrotate for $LOG_NAME wasn't set up. Check the $LOGROTATE_PATH/$LOG_NAME"
        fi
    else
        echo ""
        echo "=============================================================="
        echo "Logrotate is not installed on your system. Installation..."
        echo "=============================================================="
        echo ""

        if logrotate_install; then
            echo "Logrotate installation has been successfully completed!"
            echo ""            
            if RESULT=$(log_rotate "$ROTATE_ANSW" "$COPY_ANSW" "$COMPRESS_ANSW" "$PERM_ANSW" "$USER_ANSW" "$GROUP_ANSW" "$SU_USER" "$SU_GROUP"); then
                echo "Logrotate for $LOG_NAME has been successfully configured!"
                echo ""
                echo "************************************************************"
                echo "$RESULT"
                echo "************************************************************"
                echo ""
            else
                echo "Logrotate for $LOG_NAME wasn't set up. Check the $LOGROTATE_PATH/$LOG_NAME"
            fi
        else
            echo "Logrotate failed to install. Check the log files."
            echo ""
            exit 1
        fi
    fi

    # Ask the user if they want to perform log rotation immediately
    echo "Would you like to perform log rotation now? (Y/N)"
    read -p "> " LOGROTATE_ANSW

    case "$LOGROTATE_ANSW" in
        Y|y)
            # Perform log rotation and check for success
            if logrotate -f "$LOGROTATE_PATH/$LOG_NAME" 2>&1 | grep -E "Handling|rotating pattern:|considering log" | head -n 5; then
                echo ""
                echo "Log rotation completed successfully."
            else
                echo ""
                echo "Log rotation failed. Please check the logrotate configuration."
            fi
            ;;
        N|n)
            echo ""
            echo "Log rotation was not performed. You can do it later by running:"
            echo "logrotate -f $LOGROTATE_PATH/$LOG_NAME"
            ;;
    esac

else
    # If the user doesn't want to set up log rotation, just archive the log files
    echo "================================="
    echo "Logrotation canceled."
    echo "Log archiving has started..."
    echo "================================="
    echo ""
    echo "Please provide a destination dir path for log archive(s)"
    read -p "> " DEST_DIR

    # Check if the dir exists
    if ! is_directory "$DEST_DIR"; then
        if ! create_directory "$DEST_DIR"; then
            echo "Failed to create directory $DEST_DIR. Exiting."
            exit 1
        fi
    fi

    # Archiving
    archive_targz "$SRC_DIR" "$DEST_DIR"
    echo ""
    echo "Backup completed successfully! Check the $DEST_DIR."
    exit 0
fi
