# Backup Script

This Bash script automates the process of creating backups for a specified source directory and storing them in a specified destination directory. The script checks if the directories exist, creates a new directory if necessary, and generates a timestamped archive of the source directory.

## Features

- **Argument Handling:** Accepts source and destination directories as arguments.
- **Directory Verification:** Checks if the source and destination directories exist. If the destination directory does not exist, the user is prompted to create it.
- **Timestamped Backups:** Archives the source directory with a timestamp, ensuring unique filenames.
- **Error Handling:** Provides meaningful error messages if arguments are missing or directories do not exist.

## Requirements

- Bash shell

## Usage

```bash
./backup_script.sh <source_directory> <destination_directory>
```

## Example
```bash
./backup_script.sh /var/log/apache2 /root/backups
```

### This command will:

1. Verify the existence of /root/scripts as the source directory.
2. Check if the destination directory /root/backups exists. If it does not exist, the script will prompt the user to create it.
3. Create a compressed archive of the /root/scripts directory in /root/backups, with a filename that includes the current date and time.

### Important Notes
* The script automatically converts relative paths to absolute paths using realpath.
* The archive is created using the tar command with gzip compression (.tar.gz).
* The script includes basic error handling to guide the user through common issues like missing directories or arguments.
