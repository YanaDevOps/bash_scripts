#!/bin/bash

# Displaying the header for the monitoring process
echo "=================================================="
echo "Monitoring on server resource utilization..."
echo "=================================================="
echo ""

# Function to check CPU usage using the 'top' command
cpu_usage () {
    CPU_USAGE=$(top -b -n 1 | awk 'NR==8{printf "CPU Usage: %s%% Command: %s\n", $9,$12}')
    echo "$CPU_USAGE"
}

# Function to check memory usage using the 'free' command
mem_usage () {
    MEM_USAGE=$(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2}')
    echo "$MEM_USAGE"
}

# Function to check disk usage using the 'df' command
disk_usage () {
    df -h
}

# Function to check network activity using the 'ip' command
network_act () {
    ip -s link
}

# Function to check system uptime using the 'uptime' command
uptime_monitor () {
    uptime
}

# Prompt the user to specify the log file path
echo "Specify the /path/to/log/file.log"
read LOG_FILE
DIR=$(dirname "$LOG_FILE")

# Ensure the directory for the log file exists or create it
while [ ! -d "$DIR" ]
do
    echo "The directory $DIR does not exist."
    echo "Do you want to create it? (Y/N)"
    read CREATE_DIR

    if [ "$CREATE_DIR" == "Y" ] || [ "$CREATE_DIR" == "y" ]; then
        mkdir -p "$DIR"

        if [ $? -eq 0 ]; then
           echo "Directory $DIR created successfully."
           break
        else
            echo "Failed to create directory $DIR. Please specify a different path."
            exit 1
        fi
    else
        echo "Please specify a different path for the log file."
        read NEW_PATH
        DIR=$(dirname "$NEW_PATH")
        continue
    fi
done

# Prompt the user to specify their email for receiving the report
echo ""
echo "Specify your email: user@example.com"
read EMAIL
echo ""

# Function to generate and log the monitoring report
reporting () {
    {
    echo "=========================================="
    cpu_usage
    echo "=========================================="
    echo ""

    echo "=========================================="
    mem_usage
    echo "=========================================="
    echo ""

    echo "=========================================="
    echo "Disks Usage:"
    echo "=========================================="
    disk_usage
    echo ""

    echo "=========================================="
    echo "Network Activity:"
    echo "=========================================="
    network_act
    echo ""

    echo "=========================================="
    echo "Uptime:"
    echo "=========================================="
    uptime_monitor
    echo ""
    } | tee -a "$LOG_FILE"
}

# Function to email the report using the 'mail' command
emailing () {
    if command -v mail > /dev/null; then
        reporting
        mail -s "$(date) - Server Resource Report" "$EMAIL" < "$LOG_FILE"
        if [ $? -eq 0 ]; then
            echo "Email was successfully sent to $EMAIL"
        else
            echo "Failed to send email to $EMAIL"
        fi
    else
        echo "Command 'mail' not found. Please install 'mailutils' and try again."
    fi
}

# Start the process of generating and emailing the report
emailing
