# Backup and Log Rotation Script

## Overview

This script automates the process of archiving log files and setting up log rotation using `logrotate`. It provides a user-friendly interface for configuring log rotation, including options for compression, permissions, and user/group settings.

## Features

- **Log Archiving:** Compresses and archives log files into a `.tar.gz` file.
- **Log Rotation Configuration:** Sets up log rotation with customizable parameters, such as rotation frequency, number of copies, compression, permissions, and user/group settings.
- **Automatic Permissions Fix:** Detects and fixes insecure permissions on the parent directory of the log file if necessary.
- **Flexible User and Group Settings:** Allows configuration of the user and group for both the log file and the logrotate process.

## Usage

1. **Clone the Repository:**
    ```bash
    git clone <repository-url>
    cd backup-script
    ```
2. Run the Script:
    ```bash
    ./backup-script.sh /path/to/your/logfile.log
    ```

or
    ```bash
    ./backup-script.sh /path/to/your/logfiles
    ```

3. Follow the On-Screen Prompts:

* Choose whether to set up log rotation.
* Select the frequency of log rotation (daily, weekly, monthly, etc.).
* Define the number of copies to keep.
* Decide whether to compress rotated logs.
* Specify file permissions, user, and group for the log file.
* Choose the user and group for the log rotation actions.

4. Archive Logs Without Rotation: If you choose not to set up log rotation, the script will still archive your logs:
    ```bash
    ./backup-script.sh /path/to/your/logfile.log
    ```

or
    ```bash
    ./backup-script.sh /path/to/your/logfiles
    ```

## Example

```bash
./backup-script.sh /var/log/my_services.log
```

This will guide you through the setup process, including options for log rotation and archiving.

## Troubleshooting

* Log Rotation Does Not Occur: Ensure that the log file is not empty. If notifempty is set in the configuration, logrotate will skip empty log files.
* Permissions Issues: The script will prompt to fix any insecure permissions on the log file's parent directory.
