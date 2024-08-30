# Docker Management Script

This script is designed to simplify the management of Docker and Docker Compose environments. It allows you to install Docker, Docker Compose, Git, clone repositories, build Docker images, manage containers, and work with Docker Compose configurations all through an interactive menu.

## Features

- **Automatic Installation**: Installs Docker, Docker Compose, and Git if they are not already installed.
- **Repository Management**: Allows you to clone Git repositories and switch branches.
- **Docker Image Management**: Build, view, and remove Docker images.
- **Container Management**: Run containers in various modes (detached, with ports, with volumes, custom).
- **Docker Compose Management**: Build, start, stop, remove, view logs, and pull Docker Compose services.
- **Custom Commands**: Run custom Docker and Docker Compose commands.

## Prerequisites

- **Operating System**: Ubuntu, Debian, CentOS, RHEL, Fedora.
- **Bash**: Ensure you are running the script in a bash-compatible shell.
  
## Getting Started

1. **Clone the Repository** (Optional):
    ```bash
    git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
    cd YOUR_REPOSITORY
    ```

2. **Run the Script**:
    ```bash
    chmod +x docker-script.sh
    ./docker-script.sh
    ```

3. **Follow the Interactive Menu**:
    - The script will guide you through various options for managing Docker and Docker Compose.

## Menu Options

### Main Menu

- **1 - Docker Management**: Manage Docker images and containers.
- **2 - Launching Containers**: Run Docker containers in different modes.
- **3 - Docker Compose Management**: Manage Docker Compose services.
- **4 - Exit**: Exit the script.

### Docker Management

- **1 - Docker build**: Build a Docker image from a Dockerfile.
- **2 - Docker images**: List all Docker images.
- **3 - Docker remove images**: Remove Docker images.
- **4 - Docker custom command**: Run custom Docker commands.
- **5 - Back to main menu**: Return to the main menu.

### Docker Compose Management

- **1 - Docker Compose build**: Build services defined in a docker-compose.yml file.
- **2 - Docker Compose up**: Start services defined in a docker-compose.yml file.
- **3 - Docker Compose down**: Stop services and remove containers, networks, volumes.
- **4 - Docker Compose restart**: Restart services.
- **5 - Docker Compose logs**: View logs for services.
- **6 - Docker Compose status**: View the status of services.
- **7 - Docker Compose services**: List running services.
- **8 - Docker Compose remove**: Remove stopped service containers.
- **9 - Docker Compose pull**: Pull images for services.
- **10 - Docker Compose config**: Validate the Docker Compose file.
- **11 - Networks & Volumes**: View Docker Compose networks and volumes.
- **12 - Docker Compose custom**: Run custom Docker Compose commands.
- **13 - Back to main menu**: Return to the main menu.

## Troubleshooting

- **Permission Issues**: Ensure you have the correct permissions to run Docker and Git commands.
- **Error Messages**: The script provides error messages and exit codes. Refer to these for troubleshooting specific issues.
  
## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

