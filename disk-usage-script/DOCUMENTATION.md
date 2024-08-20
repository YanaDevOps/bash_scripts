
### DOCUMENTATION.md

# Documentation for Disk Usage Monitoring Script

This document provides a detailed explanation of the `disk_usage_script.sh`, covering its functionality, internal logic, error handling, and potential extensions.

## Script Overview

The `disk_usage_script.sh` is a Bash script designed to automate the monitoring of disk space usage for specified disks or directories. The script provides functionality to send alerts when disk usage exceeds a user-defined threshold and logs the results for further analysis.

### Key Features

- **Argument Handling:** Accepts multiple disk or directory paths as arguments, allowing flexible monitoring.
- **Disk Usage Check:** Uses the `df` command to retrieve disk usage information and compares it with a predefined threshold.
- **Email Notifications:** Sends an email alert if the disk usage exceeds the threshold.
- **Logging:** Records all disk usage data to a specified log file, ensuring that data is preserved for future reference.
- **Automatic Directory Creation:** If the directory for the log file does not exist, the script prompts the user to create it.

## Requirements

- **Bash shell**: The script is written in Bash and should be run in a Bash environment.
- **Mail command**: The `mail` command must be configured for sending email notifications.

## How to Use

1. **Running the Script:**
   - The script is executed from the command line by passing the paths to the disks or directories to monitor.
   - Example:
   ```bash
     ./disk_usage_script.sh / /home /var
   ```

2. **Email Setup:**
   - The script prompts the user to enter an email address where alerts will be sent. Ensure that the `mail` command is configured on your system.

3. **Logging Setup:**
   - The script asks for a path to a log file. If the specified directory does not exist, the script will prompt the user to create it.

## Script Workflow

1. **Argument Parsing:**
   - The script checks if any arguments were provided. If not, it terminates and provides usage instructions.

2. **Email and Log File Setup:**
   - The user is prompted to enter an email address and the path to a log file.

3. **Directory Verification:**
   - The script checks if the directory for the log file exists. If not, it prompts the user to create it.

4. **Disk Usage Monitoring:**
   - For each disk or directory provided, the script retrieves the disk usage information using the `df` command.
   - The script checks if the disk usage exceeds the predefined threshold (default is 80%). If so, an email alert is sent.

5. **Logging:**
   - Disk usage data is logged to the specified file with a timestamp.

## Error Handling

- **Missing Arguments:** The script checks if any arguments were provided. If not, it exits with a usage message.
- **Non-existent Directories:** If the directory for the log file does not exist, the script prompts the user to create it or specify a different path.
- **Disk Information Retrieval:** The script checks if it successfully retrieved disk information. If not, it skips that disk and continues with the next one.

## How to Extend

- **Custom Thresholds:** Modify the `THRESHOLD` variable to set a custom threshold for disk usage alerts.
- **Additional Notifications:** Integrate the script with other notification systems (e.g., Slack, SMS).
- **Scheduled Runs:** Use `cron` to schedule the script to run at regular intervals for continuous monitoring.

## Conclusion

This script is a powerful tool for monitoring disk usage, sending alerts, and logging data for later review. It is flexible and can be adapted to a wide range of use cases in system administration.
