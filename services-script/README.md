# Service Management Script

This Bash script allows you to manage services on your Linux system, including starting, stopping, and restarting services, as well as checking for updates on your system. The script supports both automatic and manual service management modes.

## Features

- **Automatic Service Management:** Automatically start inactive services or restart active ones.
- **Manual Service Management:** Manually choose to start, stop, or restart specific services.
- **Update Checking:** Check for available updates on your system and apply them if desired.
- **Logging:** Logs actions and errors to specified log files.

## Requirements

- A Linux-based operating system (e.g., Ubuntu, Debian, CentOS, RHEL, Fedora).
- `systemctl` command available for managing services.
- `apt` or `yum` package manager for checking and applying updates.

## Usage

### Running the Script

1. Clone the repository or download the script to your local machine.
2. Make the script executable:
   ```bash
   chmod +x services-script.sh
   ```
3. Run the script with the services you want to manage as arguments:
   ```bash
   ./services-script.sh apache2 nginx
   ```

### Script Flow
1. Specify Log File: The script will prompt you to specify the path to the log file where all actions will be recorded.
2. Automatic or Manual Management: Choose whether you want the script to automatically manage services or allow manual control.
   * If you choose automatic management, the script will either start inactive services or restart active ones.
   * If you choose manual management, you will be prompted to start, stop, or restart each specified service.
3. Update Check: Finally, the script will ask if you want to check for available system updates.

### Example
   ```bash
   ./services-script.sh apache2 nginx
   ```
