
### `DOCUMENTATION.md`

# Server Resource Monitoring Script Documentation

## Overview

This script provides a comprehensive overview of server resource utilization, including CPU, memory, disk usage, network activity, and system uptime. The script generates a report that can be saved to a log file and sent via email.

## Detailed Functionality

### CPU Usage Monitoring

- **Command Used**: `top -b -n 1`
- **Description**: The script captures the CPU usage by extracting data from the `top` command, which provides a snapshot of the CPU load and the process using the most CPU at the time of execution.
- **Output**: 
  - CPU usage percentage
  - Command consuming the most CPU

### Memory Usage Monitoring

- **Command Used**: `free -m`
- **Description**: The script captures the memory usage, including total memory, used memory, and the percentage of memory being used.
- **Output**:
  - Memory used
  - Total memory available
  - Percentage of memory used

### Disk Usage Monitoring

- **Command Used**: `df -h`
- **Description**: The script lists all mounted file systems and reports their total size, used space, available space, and usage percentage.
- **Output**:
  - Filesystem
  - Size
  - Used space
  - Available space
  - Usage percentage
  - Mount point

### Network Activity Monitoring

- **Command Used**: `ip -s link`
- **Description**: The script captures detailed statistics on network activity, including the number of bytes and packets transmitted and received on each network interface.
- **Output**:
  - Interface name
  - Bytes and packets transmitted and received
  - Errors and dropped packets

### System Uptime

- **Command Used**: `uptime`
- **Description**: The script reports the system's uptime, including the current time, the duration the system has been up, the number of users currently logged in, and the system load averages.
- **Output**:
  - Current time
  - Uptime
  - Number of users
  - Load averages

## Report Generation

The script generates a detailed report containing all the monitored metrics. This report is saved to a specified log file and can be sent via email if configured.

### Log File

- The user is prompted to specify the path to the log file where the report will be saved. If the specified directory does not exist, the script offers to create it.

### Emailing the Report

- The script can email the generated report using the `mail` command. The user is prompted to enter an email address for the report to be sent to. The `mailutils` package must be installed for this feature to work.

## Error Handling

- **Directory Creation**: If the log file's directory does not exist, the script prompts the user to create it. If creation fails, the user is prompted to specify a different path.
- **Email Sending**: The script checks if the `mail` command is available. If not, it instructs the user to install `mailutils`. It also confirms whether the email was successfully sent.

## Usage Instructions

1. Run the script: `./monitoring-script.sh`
2. Follow the prompts to specify the log file path and email address.
3. The report will be generated and saved, and optionally sent via email.

## Dependencies

- **Bash**: Ensure that you are running the script in a Bash shell.
- **mailutils** (optional): Required for sending the report via email.

## Conclusion

This script provides a simple yet powerful way to monitor server resource utilization and generate detailed reports. It is ideal for system administrators who need to keep an eye on server performance and resource usage.
