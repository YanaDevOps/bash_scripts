# Documentation for Backup Script

This document provides a detailed explanation of the `backup_script.sh`, covering its functionality, internal logic, error handling, and potential extensions.

## Script Overview

The `backup_script.sh` is a Bash script designed to automate the process of creating backups for a specified directory. The script allows users to specify both the source directory (to be backed up) and the destination directory (where the backup will be stored) as command-line arguments. The backup file is saved as a `.tar.gz` archive, with a timestamped filename to ensure uniqueness.

### Key Steps in the Script

1. **Argument Validation:**
   - The script checks if the user has provided both the source and destination directory paths.
   - If either of the required arguments is missing, the script outputs an error message and exits.

2. **Path Conversion:**
   - The script uses `realpath` to convert any relative paths provided by the user into absolute paths. This ensures that the script works consistently, regardless of the current working directory.

3. **Directory Existence Check:**
   - The script verifies that the source directory exists. If the directory does not exist, the script exits with an error message.
   - For the destination directory, the script checks if it exists. If not, the user is prompted to create the directory. If the user agrees, the script creates the directory using `mkdir -p`.

4. **Backup Creation:**
   - The script uses the `tar` command to create a compressed archive (`.tar.gz`) of the source directory.
   - The archive filename includes the current date and time, which prevents overwriting previous backups and helps in identifying different backup points.

5. **Completion Notification:**
   - After successfully creating the backup, the script outputs a message indicating that the backup process has completed successfully.

## How to Extend

### Logging

You can enhance the script by adding logging functionality to keep a record of backup operations. This can be done by redirecting the output of each command to a log file.

### Example:

```bash
LOG_FILE="$DEST_DIR/backup_log_$DATE.txt"
exec > >(tee -a $LOG_FILE) 2>&1
```

### Email Notifications
To further improve the script, you could add a feature to send email notifications after the backup is completed or if an error occurs. This can be done using the mail command or other email utilities available on your system.

### Scheduling with Cron
You can schedule this script to run automatically at specific intervals using cron. Here is an example of how to schedule the script to run every day at midnight:
```bash
0 0 * * * /path/to/backup_script.sh /source/directory /destination/directory
```

## Error Handling
### Missing Arguments
If the script is executed without providing the required arguments (source and destination directories), it will terminate with the following message:
```bash
Please, set the source and destination dirs paths
```

### Non-existent Directories
The script checks whether the provided source directory exists. If not, it outputs:
```bash
The source directory doesn't exist: /path/to/source
```

For the destination directory, if it does not exist, the script prompts the user:
```bash
The destination directory doesn't exist: /path/to/destination
Create a directory? Y(yes)/N(no)?
```

Depending on the user's input, the script will either create the directory or terminate, asking the user to provide a valid directory.

### "tar" Warnings
When creating the archive, you may encounter a warning message like:
```bash
tar: Removing leading `/' from member names
```

This is a standard behavior of the tar command when archiving absolute paths. It can be safely ignored or suppressed if needed.

## Additional Notes
* Compatibility: The script is written for Bash and should work on most Unix-like systems. Ensure that tar, realpath, and other necessary utilities are installed and available on your system.
* Backup Location: Ensure that the destination directory has sufficient space to store the backup files, especially if the source directory is large.
* Security: If you plan to back up sensitive data, consider adding encryption to the backup process.
