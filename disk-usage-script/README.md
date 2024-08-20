# Disk Usage Monitoring Script

This Bash script is designed to monitor the usage of specified disks or directories and alert the user if the disk usage exceeds a predefined threshold. The script also logs the disk usage data and provides an option to send an email notification if the threshold is breached.

## Features

- **Multiple Disk Monitoring:** Monitor multiple disks or directories by passing them as arguments to the script.
- **Threshold Alerts:** Set a threshold for disk usage. If usage exceeds this threshold, an email alert is sent.
- **Logging:** Logs disk usage data to a specified file, ensuring that all activity is recorded for later review.
- **Automatic Directory Creation:** If the specified directory for the log file does not exist, the script prompts the user to create it.
- **Customizable Email Alerts:** Allows the user to specify an email address to receive disk usage alerts.

## Requirements

- Bash shell
- `mail` command must be configured on your system for email notifications

## Usage

```bash
./disk_usage_script.sh /path/to/disk1 /path/to/disk2 ...
```

## Example
```bash
./disk_usage_script.sh / /home /var
```

This command will:

* Prompt you to enter an email address for alerts.
* Ask for the path to a log file where the disk usage data will be recorded.
* Monitor the specified disks (/, /home, /var) and output the disk usage.
* Send an email alert if the usage of any disk exceeds the threshold (default is 80%).

## Important Notes
* Ensure that the mail command is correctly configured on your system to send email notifications.
* The script uses a default threshold of 80%. You can change this value by modifying the THRESHOLD variable in the script.
