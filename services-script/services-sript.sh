#!/bin/bash

# Extract file name without path and extension
LOG_FILE=""
echo "=============================================================="
echo "Specify the path to the log file (e.g., /path/to/log):"
echo "=============================================================="
read LOG_FILE

BASENAME=$(basename "$LOG_FILE" .log)
# Adding the _errors suffix and restoring the extension
ERROR_LOG_FILE=$(dirname "$LOG_FILE")/"${BASENAME}_errors.log"

# Checking if the specified directory exists
DIR=$(dirname "$LOG_FILE")

if [ ! -d "$DIR" ]; then
    echo "=============================================================="
    echo "The directory $DIR does not exist."
    echo "Do you want to create it? (Y/N)"
    echo "=============================================================="
    read CREATE_DIR

    if [ "$CREATE_DIR" == "Y" ] || [ "$CREATE_DIR" == "y" ]; then
        mkdir -p "$DIR"
        if [ $? -eq 0 ]; then
            echo ""
            echo "Directory $DIR created successfully."
            echo ""
        else
            echo ""
            echo "Failed to create directory $DIR. Please specify a different path."
            echo ""
            exit 1
        fi
    else
        echo ""
        echo "Please specify a different path for the log file."
        echo ""
        exit 1
    fi
fi

# Function for determining the user distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "Cannot determine your Linux distribution."
        exit 1
    fi
}

# User distribution to a variable
DISTR=$(detect_distro)

# Array of passed arguments
SERVICES=("$@")

# A function that handles all actions with services (start, stop, restart) and logs them
manage_service() {
    local ACTION=$1
    local SERVICE=$2

    case $ACTION in
        start)
            systemctl start "$SERVICE"
            if [ $? -eq 0 ]; then
                echo "$(date) $SERVICE has been successfully started!"
                echo "$(date) $SERVICE has been successfully started!" >> "$LOG_FILE"
            else
                echo "$(date) Failed to start the $SERVICE service. Check the logs of the service."
                echo "$(date) Failed to start the $SERVICE service. Check the logs of the service." >> "$ERROR_LOG_FILE"
            fi
            ;;
        stop)
            systemctl stop "$SERVICE"
            if [ $? -eq 0 ]; then
                echo "$(date) $SERVICE has been successfully stopped!"
                echo "$(date) $SERVICE has been successfully stopped!" >> "$LOG_FILE"
            else
                echo "$(date) Failed to stop the $SERVICE service. Check the logs of the service."
                echo "$(date) Failed to stop the $SERVICE service. Check the logs of the service." >> "$ERROR_LOG_FILE"
            fi
            ;;
        restart)
            systemctl restart "$SERVICE"
            if [ $? -eq 0 ]; then
                echo "$(date) $SERVICE has been successfully restarted!"
                echo "$(date) $SERVICE has been successfully restarted!" >> "$LOG_FILE"
            else
                echo "$(date) Failed to restart the $SERVICE service. Check the logs of the service."
                echo "$(date) Failed to restart the $SERVICE service. Check the logs of the service." >> "$ERROR_LOG_FILE"
            fi
            ;;
        *)
            echo "Invalid action: $ACTION"
            ;;
    esac
}

# A function that checks if there are updates for the specified services, and notifies the user when an update is needed
check_for_updates() {
    local DISTR=$1

    if [ "$DISTR" == "ubuntu" ] || [ "$DISTR" == "debian" ]; then
        sudo apt update
        UPDATES=$(apt list --upgradable 2>/dev/null | grep -v "Listing...")
    elif [ "$DISTR" == "centos" ] || [ "$DISTR" == "rhel" ] || [ "$DISTR" == "fedora" ]; then
        UPDATES=$(sudo yum check-update)
    fi

    if [ -n "$UPDATES" ]; then
        echo "The following updates are available:"
        echo "$UPDATES"
        echo ""
        echo "Would you like to update? Y/N"
        read UPD_ANSW
        if [ "$UPD_ANSW" == "Y" ] || [ "$UPD_ANSW" == "y" ]; then
            if [ "$DISTR" == "ubuntu" ] || [ "$DISTR" == "debian" ]; then
                sudo apt upgrade -y
            elif [ "$DISTR" == "centos" ] || [ "$DISTR" == "rhel" ] || [ "$DISTR" == "fedora" ]; then
                sudo yum update -y
            fi
            echo "System has been updated."
        else
            echo "Update canceled."
        fi
    else
        echo "Your system is up to date."
    fi
}

# If no arguments are passed, print the instruction and terminate the script
if [ "$#" -eq 0 ]; then
    echo ""
    echo "Please mention all the services you need to check."
    echo "Example: $0 apache2 nginx"
    echo ""
    exit 1
fi

# Check if the user wants to manage services automatically
echo ""
echo "======================================================================================="
echo "Would you like to automatically manage services? (start inactive/restart active) Y/N"
echo "======================================================================================="
echo ""
read AUTO_ANSW

# Output formatting
echo ""
printf "%-15s %-20s %-10s\n" "-------" "---------" "----------"
printf "%-15s %-20s %-10s\n" "Service" "Status" "Enabled"
printf "%-15s %-20s %-10s\n" "-------" "---------" "----------"
echo ""

for SERVICE in "${SERVICES[@]}"; do
    SERVICE_INFO=$(systemctl status "$SERVICE")
    if [ $? -eq 4 ]; then
        echo ""
        echo "The service $SERVICE does not exist."
        echo ""
        continue
    fi

    # Get a string with the service status
    ACTIVE_STATUS=$(systemctl is-active "$SERVICE")
    # We receive information about the service activation
    ENABLED_STATUS=$(systemctl is-enabled "$SERVICE" 2>/dev/null)
    
    # Print the status and information about the service activation
    printf "%-15s %-20s %-10s\n" "$SERVICE" "$ACTIVE_STATUS" "$ENABLED_STATUS"

    # Automatic management
    if [ "$AUTO_ANSW" == "Y" ] || [ "$AUTO_ANSW" == "y" ]; then
        if [ "$ACTIVE_STATUS" != "active" ]; then
            echo ""
            echo "Attempting to start $SERVICE..."
            echo ""
            manage_service start "$SERVICE"
        elif [ "$ACTIVE_STATUS" == "active" ]; then
            echo ""
            echo "Attempting to restart $SERVICE..."
            echo ""
            manage_service restart "$SERVICE"
        fi
    fi
done

# Manual service management
if [ "$AUTO_ANSW" != "Y" ] || [ "$AUTO_ANSW" != "y" ]; then
    echo ""
    echo "==========================================================="
    echo "Would you like to start/stop/restart any service? Y/N"
    echo "==========================================================="
    echo ""
    read MANUAL_ANSW

    if [ "$MANUAL_ANSW" == "Y" ] || [ "$MANUAL_ANSW" == "y" ]; then
        echo ""
        echo "What service(s) would you like to manage? e.g. apache2 nginx ..."
        echo ""
        read -a SERVICE_NAMES

        for SERVICE in "${SERVICE_NAMES[@]}"; do
            echo ""
            echo "======================="
            echo "$SERVICE:"
            echo "======================="
            echo "1 - Start"
            echo "2 - Stop"
            echo "3 - Restart"
            echo "======================="
            echo ""
            read ACTION_ANSW

            case $ACTION_ANSW in
                1)
                    manage_service start "$SERVICE"
                    ;;
                2)
                    manage_service stop "$SERVICE"
                    ;;
                3)
                    manage_service restart "$SERVICE"
                    ;;
                *)
                    echo "Invalid option for $SERVICE"
                    ;;
            esac
        done
    else
        exit 0
    fi
fi

# Updates checking
echo ""
echo "==========================================================="
echo "Would you like to check updates for your services? Y/N"
echo "==========================================================="
echo ""
read CHECK_ANSW

if [ "$CHECK_ANSW" == "Y" ] || [ "$CHECK_ANSW" == "y" ]; then
    check_for_updates "$DISTR"
else
    echo "Update check canceled."
    exit 0
fi

echo "================================================================="
echo "You can check your logs via "$LOG_FILE" and "$ERROR_LOG_FILE"!"
echo "================================================================="
