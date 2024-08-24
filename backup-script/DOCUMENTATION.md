# Backup Script Documentation

## Overview
This script is designed to create backups of specified directories or files. It compresses the source directory or file into a .tar.gz archive and saves it to a specified destination directory. Additionally, the script includes an option to set up log rotation for log files.

## Features
* Automatic Backup Creation: Compresses and archives directories or files.
* Log Rotation Configuration: Option to configure log rotation for log files.
* Directory Creation: Automatically creates directories if they don't exist.
* Error Handling: Provides informative messages and prompts in case of errors or missing input.

## Requirements
* Bash Shell: The script is written in Bash and should be run in a Bash shell.
* tar: The script uses the tar command to create backups.
* logrotate: The script optionally configures log rotation using logrotate.

## Usage

### Running the Script
To run the script, use the following syntax:
    ```bash
    ./backup-script.sh /path/to/source /path/to/destination
    ```
Arguments
* /path/to/source: The path to the directory or file you want to back up.
* /path/to/destination: The path where the backup archive should be stored.

## Example
    ```bash
    ./backup-script.sh /var/log/my_services.log /backups
    ```
This command will back up the /var/log/my_services.log file to the /backups directory.

## Script Functions
1. Argument Checking
* The script checks if the user has provided the required source directory/file path.
* If the required argument is missing, the script outputs an error message and exits.

2. Path Conversion
* The script uses realpath to convert any relative paths provided by the user into absolute paths. This ensures consistent behavior regardless of the current working directory.

3. Directory Existence Check
* Source Directory/File: The script verifies that the source directory or file exists. If not, the script exits with an error message.
* Destination Directory: If the destination directory does not exist, the user is prompted to create it. If the user agrees, the script creates the directory using mkdir -p.

4. Log Rotation Configuration (Optional)
* If the user opts to set up log rotation, the script guides the user through configuring logrotate for the specified log file.
* The script supports customization of log rotation frequency, number of backups to keep, compression, permissions, and the user/group under which the rotation should be performed.

5. Backup Creation
* The script uses tar to create a compressed archive (.tar.gz) of the source directory or file.
* The archive filename includes the current date and time to prevent overwriting previous backups and to help identify different backup points.

6. Completion Notification
* After successfully creating the backup, the script outputs a message indicating that the backup process has completed successfully.

## Advanced Features

### Logging
To enhance the script, you can add logging functionality to keep a record of backup operations. This can be achieved by redirecting the output of each command to a log file.

#### Example:
    ```bash
    LOG_FILE="$DEST_DIR/backup_log_$DATE.txt"
    exec > >(tee -a $LOG_FILE) 2>&1
    ```
### Email Notifications
You could add a feature to send email notifications after the backup is completed or if an error occurs. This can be done using the mail command or other email utilities available on your system.

### Scheduling with Cron
You can schedule this script to run automatically at specific intervals using cron. Here is an example of how to schedule the script to run every day at midnight:
    ```bash
    0 0 * * * /path/to/backup_script.sh /source/directory /destination/directory
    ```

## Error Handling

### Missing Arguments
If the script is executed without providing the required arguments, it will terminate with the following message:
    ```bash
    Please, set the source and destination dirs paths
    ```

### Non-existent Directories
* Source Directory/File: If the source directory or file does not exist, the script outputs an error message and exits.
    ```bash
    The source directory doesn't exist: /path/to/source
    ```
* Destination Directory: If the destination directory does not exist, the script prompts the user to create it. Based on the user's input, the script will either create the directory or exit.
    ```bash
    The destination directory doesn't exist: /path/to/destination
    Create a directory? Y(yes)/N(no)?
    ```
Depending on the user's response, the script will either create the directory or terminate, asking the user to provide a valid directory.

## Conclusion
This script is a flexible tool for managing backups and log rotation, offering user prompts and error handling to ensure smooth operation. It can be easily extended with logging, email notifications, and scheduling to fit various use cases.

