# Server Resource Monitoring Script

This script is designed to monitor the resource utilization of a Linux server, including CPU usage, memory usage, disk usage, network activity, and system uptime. It generates a report that can be saved to a log file and optionally sent via email.

## Features

- **CPU Usage Monitoring**: Provides a snapshot of the current CPU usage.
- **Memory Usage Monitoring**: Reports the amount of memory used, total memory, and the percentage of memory used.
- **Disk Usage Monitoring**: Displays the disk usage of all mounted file systems.
- **Network Activity Monitoring**: Shows detailed statistics on network activity.
- **System Uptime**: Displays the system's uptime, including load averages.
- **Report Generation**: Saves the report to a specified log file.
- **Email Report**: Optionally sends the report to a specified email address.

## Prerequisites

- **Bash**: The script should be run in a Bash shell.
- **mailutils**: Required if you want to send the report via email. Install it using:
  
  ```bash
  sudo apt-get install mailutils
  ```

## Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
   cd YOUR_REPOSITORY
   ```
2. Make the script executable:
   ```bash
   chmod +x monitoring-script.sh
   ```
3. Run the script:
   ```bash
   ./monitoring-script.sh
   ```

### You will be prompted to:

* Specify the path to the log file.
* Enter your email address if you want to receive the report via email.

### Example

```bash
==========================================
CPU Usage:
CPU Usage: 10.5% Command: apache2
==========================================

==========================================
Memory Usage: 512/4096MB (12.50%)
==========================================

==========================================
Disk Usage:
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       100G   50G   50G  50% /
==========================================

==========================================
Network Activity:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX:  bytes packets errors dropped  missed   mcast
        102432    1082      0       0       0       0
    TX:  bytes packets errors dropped carrier collsns
        102432    1082      0       0       0       0
==========================================

==========================================
Uptime:
 13:45:33 up  1:49,  1 user,  load average: 0.00, 0.00, 0.00
==========================================
```
