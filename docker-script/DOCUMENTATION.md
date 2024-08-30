# Docker Management Script Documentation

## Overview

The Docker Management Script provides a comprehensive interface for managing Docker environments on Linux-based systems. It is designed to streamline Docker and Docker Compose operations, including installation, image and container management, and service orchestration using Docker Compose.

## Table of Contents

1. [Installation](#installation)
2. [Usage](#usage)
3. [Functions](#functions)
   - [docker_check](#docker_check)
   - [docker_install](#docker_install)
   - [git_check](#git_check)
   - [git_install](#git_install)
   - [docker_build](#docker_build)
   - [docker_run_detached](#docker_run_detached)
   - [docker_compose_up](#docker_compose_up)
   - [docker_compose_down](#docker_compose_down)
   - [docker_compose_logs](#docker_compose_logs)
4. [Error Handling](#error-handling)
5. [Advanced Usage](#advanced-usage)
6. [License](#license)

## Installation

The script automatically installs Docker, Docker Compose, and Git if they are not detected on the system. The script is designed for Ubuntu, Debian, CentOS, RHEL, and Fedora distributions.

1. **Download the Script**:
    ```bash
    git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
    cd YOUR_REPOSITORY
    ```

2. **Make the Script Executable**:
    ```bash
    chmod +x docker-script.sh
    ```

3. **Run the Script**:
    ```bash
    ./docker-script.sh
    ```

## Usage

The script features an interactive menu that provides the following capabilities:

- **Docker Management**: Build and manage Docker images and containers.
- **Docker Compose Management**: Build, start, stop, and manage services defined in a docker-compose.yml file.
- **Custom Commands**: Execute custom Docker and Docker Compose commands.

## Functions

### docker_check

Checks if Docker is installed on the system.

**Usage**:
```bash
docker_check
```

### Returns:
* 0 if Docker is installed.
* 1 if Docker is not installed.

### docker_install
Installs Docker on the system based on the detected distribution.

Usage:
``` bash
docker_install
```

### Dependencies:
* 'docker_check'

### git_check
Checks if Git is installed on the system.

Usage:
```bash
git_check
```

Returns:
* 0 if Git is installed.
* 1 if Git is not installed.

### git_install
Installs Git on the system based on the detected distribution.

Usage:
```bash
git_install
```

Dependencies:
* 'git_check'

### docker_build
Builds a Docker image from the specified Dockerfile.

Usage:
```bash
docker_build
```

Arguments:
* DOCKERFILE_PATH: Path to the Dockerfile.
* IMAGE_NAME: Name of the Docker image.
* docker_run_detached
* Runs a Docker container in detached mode.

Usage:
```bash
docker_run_detached "container_name"
```

Arguments:
* container_name: The name to assign to the running container.

### docker_compose_up
Starts services defined in the docker-compose.yml file.

Usage:
```bash
docker_compose_up
```

### docker_compose_down
Stops services and removes containers, networks, and volumes.

Usage:
```bash
docker_compose_down
```

### docker_compose_logs
Displays logs from running Docker Compose services.

Usage:
```bash
docker_compose_logs
```

### Error Handling
The script includes basic error handling to inform the user of any issues during execution. Errors are logged, and exit codes are returned for troubleshooting.

### Advanced Usage
Advanced users can modify the script to suit specific environments by editing the variables and functions as needed.
