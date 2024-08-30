#!/bin/bash

# Main variables
DOCKERFILE_PATH=""
TAG=""
SERVICES=() # Empty array the will be initialized by the user in the docker compose section
DOCKER_COMPOSE_PATH=""
CONTAINER_NAME=""

# Just for better user experience. Simulate installation processes.
dynamic_progress_bar() {
    local pid=$1  # Get the PID of the process
    local delay=0.1  # Update interval (in seconds)
    local spinstr='|/-\'  # Characters for rotation

    echo -n "["
    
    while kill -0 $pid 2> /dev/null; do
        local temp=${spinstr#?}
        printf " [%c] " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b\b\b\b"
    done
    
    echo -n "==============================] Done!"
    echo ""
    wait $pid  # Waiting for the process to complete
}

# Determining the user distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo -e "\nCannot determine your Linux distribution.\n"
        exit 1
    fi
}

docker_check () {
    if docker --version > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi  
}

dockercompose_check () {
    if docker compose --version > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi  
}

git_check () {
    if git --version > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi  
}

yq_check () {
    if command -v yq > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

docker_install () {
    if ! docker_check; then  # Check if Docker is installed
        case $(detect_distro) in  # Detect the distribution
            ubuntu|debian)
            {
                # Update package lists and install required dependencies
                sudo apt-get update -y > /dev/null 2>&1
                sudo apt-get install -y ca-certificates curl > /dev/null 2>&1
                
                # Create directory for keys and download Docker's official GPG key
                sudo install -m 0755 -d /etc/apt/keyrings
                sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc > /dev/null 2>&1
                sudo chmod a+r /etc/apt/keyrings/docker.asc

                # Add Docker repository to Apt sources
                echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -y > /dev/null 2>&1

                # Install the latest version of Docker
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker compose-plugin > /dev/null 2>&1
            } &
                pid=$! # Get the PID of the installation process

                dynamic_progress_bar $pid # Call the dynamic progress bar function

                wait $pid  # Wait for the installation to finish

                if [ $? -eq 0 ]; then
                    echo -e "\nDocker installation completed successfully.\n"
                else
                    echo -e "\nDocker installation failed. Please check the logs for details.\n"
                    exit 1
                fi
                ;;
            centos|rhel)
            {
                # Install yum-utils for managing repositories
                sudo yum install -y yum-utils > /dev/null 2>&1

                # Add Docker repository
                sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo > /dev/null 2>&1

                # Install the latest version of Docker
                sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker compose-plugin > /dev/null 2>&1
            } &
                pid=$! # Get the PID of the installation process

                dynamic_progress_bar $pid # Call the dynamic progress bar function

                wait $pid  # Wait for the installation to finish

                if [ $? -eq 0 ]; then
                    echo -e "\nDocker installation completed successfully.\n"

                    # Start Docker
                    sudo systemctl start docker
                else
                    echo -e "\nDocker installation failed. Please check the logs for details.\n"
                    exit 1
                fi
                ;;
            fedora)
            {
                # Install dnf-plugins-core for managing repositories
                sudo dnf -y install dnf-plugins-core > /dev/null 2>&1

                # Add Docker repository
                sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo > /dev/null 2>&1
[O
                # Install the latest version of Docker
                sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker compose-plugin > /dev/null 2>&1
            } &
                pid=$! # Get the PID of the installation process

                dynamic_progress_bar $pid # Call the dynamic progress bar function

                wait $pid  # Wait for the installation to finish

                if [ $? -eq 0 ]; then
                    echo -e "\nDocker installation completed successfully.\n"

                    # Start Docker
                    sudo systemctl start docker
                else
                    echo -e "\nDocker installation failed. Please check the logs for details.\n"
                    exit 1
                fi
                ;;
            *) 
                echo -e "\nYour distribution is not supported by this script.\n"
                exit 1
                ;;
        esac
    else
        echo -e "\nDocker is already installed. Skipping installation.\n"
    fi
}

docker_compose_install () {
    if ! dockercompose_check; then
        case $(detect_distro) in  # Detect the distribution
            ubuntu|debian)
            {
                sudo apt-get update -y > /dev/null 2>&1
                sudo apt-get install -y docker compose-plugin > /dev/null 2>&1
            } &
                pid=$! # Get the PID of the installation process

                dynamic_progress_bar $pid # Call the dynamic progress bar function

                wait $pid  # Wait for the installation to finish

                # Verify that Docker Compose is installed correctly by checking the version.
                if docker compose version > /dev/null 2>&1; then
                    echo -e "\ndocker compose successfully installed!\n"
                    return 0
                else
                    echo -e "\nThe docker compose installation could not be completed. Check the log files.\n"
                    return 1
                fi
                ;;
            centos|fedora|rhel)
            {
                sudo yum update -y > /dev/null 2>&1
                sudo yum install -y docker compose-plugin > /dev/null 2>&1
            } &
                pid=$! # Get the PID of the installation process

                dynamic_progress_bar $pid # Call the dynamic progress bar function

                wait $pid  # Wait for the installation to finish
                
                # Verify that Docker Compose is installed correctly by checking the version.
                if docker compose version > /dev/null 2>&1; then
                    echo -e "\ndocker compose successfully installed!\n"
                    return 0
                else
                    echo -e "\nThe docker compose installation could not be completed. Check the log files.\n"
                    return 1
                fi
                ;;
            *)
                exit 1
                ;;
        esac
    else
        echo -e "\ndocker compose is already installed. Skipping installation.\n"
    fi
}


git_install () {
    if ! git_check; then
        case $(detect_distro) in  # Detect the distribution
            ubuntu|debian)
            {
                sudo apt-get update -y > /dev/null 2>&1
                sudo apt-get install git -y > /dev/null 2>&1
            } &
                pid=$! # Get the PID of the installation process

                dynamic_progress_bar $pid # Call the dynamic progress bar function

                wait $pid  # Wait for the installation to finish

                # Verify that Git is installed correctly by checking the version.
                if git --version > /dev/null 2>&1; then
                    echo -e "\nGit successfully installed!\n"
                    return 0
                else
                    echo -e "\nThe Git installation could not be completed. Check the log files.\n"
                    return 1
                fi
                ;;
            centos|rhel)
            {
                sudo yum update -y > /dev/null 2>&1
                sudo yum install git -y > /dev/null 2>&1
            } &
                pid=$! # Get the PID of the installation process

                dynamic_progress_bar $pid # Call the dynamic progress bar function

                wait $pid  # Wait for the installation to finish

                # Verify that Git is installed correctly by checking the version.
                if git --version > /dev/null 2>&1; then
                    echo -e "\nGit successfully installed!\n"
                    return 0
                else
                    echo -e "\nThe Git installation could not be completed. Check the log files.\n"
                    return 1
                fi
                ;;
            fedora)
            {
                sudo dnf update -y > /dev/null 2>&1
                sudo dnf install git -y > /dev/null 2>&1
            } &
                pid=$! # Get the PID of the installation process

                dynamic_progress_bar $pid # Call the dynamic progress bar function

                wait $pid  # Wait for the installation to finish

                # Verify that Git is installed correctly by checking the version.
                if git --version > /dev/null 2>&1; then
                    echo -e "\nGit successfully installed!\n"
                    return 0
                else
                    echo -e "\nThe Git installation could not be completed. Check the log files.\n"
                    return 1
                fi
                ;;
            *)
                echo -e "\nYour distribution is not supported by this script.\n"
                exit 1
                ;;
        esac
    else
        echo -e "\nGit is already installed. Skipping installation.\n" 
    fi
}

yq_install () {
    if ! yq_check; then  # Check if Docker is installed
        case $(detect_distro) in  # Detect the distribution
            ubuntu|debian)
            {
            # Update package lists and install yq via snap
            sudo apt-get update -y > /dev/null 2>&1
            sudo snap install yq                
            } &
                pid=$! # Get the PID of the installation process

                dynamic_progress_bar $pid # Call the dynamic progress bar function

                wait $pid  # Wait for the installation to finish

                if [ $? -eq 0 ]; then
                    echo -e "\nyq successfully installed!\n"
                    return 0
                else
                    echo -e "\nThe yq installation could not be completed. Check the log files.\n"
                    return 1
                fi
                ;;
            centos|rhel)
            {
                # Install snapd if it's not already installed, and install yq via snap
                sudo yum install -y epel-release > /dev/null 2>&1
                sudo yum install -y snapd > /dev/null 2>&1
                sudo systemctl enable --now snapd.socket
                sudo ln -s /var/lib/snapd/snap /snap
                sudo snap install yq
            } &
                pid=$! # Get the PID of the installation process

                dynamic_progress_bar $pid # Call the dynamic progress bar function

                wait $pid  # Wait for the installation to 
                
                if [ $? -eq 0 ]; then
                    echo -e "\nyq successfully installed!\n"
                    return 0
                else
                    echo -e "\nThe yq installation could not be completed. Check the log files.\n"
                    return 1
                fi
                ;;
            fedora)
            {
                # Install yq via dnf
                sudo dnf install -y yq > /dev/null 2>&1
            } &
                pid=$! # Get the PID of the installation process

                dynamic_progress_bar $pid # Call the dynamic progress bar function

                wait $pid  # Wait for the installation to finish

                if [ $? -eq 0 ]; then
                    echo -e "\nyq successfully installed!\n"
                    return 0
                else
                    echo -e "\nThe yq installation could not be completed. Check the log files.\n"
                    return 1
                fi
                ;;
            *) 
                echo -e "\nYour distribution is not supported by this script.\n"
                exit 1
                ;;
        esac
    else
        echo -e "\nDocker is already installed. Skipping installation.\n"
    fi
}

git_clone () {
    local REPO_URL=$1
    local REPO_DIR=$2

    if [ -d "$REPO_DIR" ]; then
        if [ -d "$REPO_DIR/.git" ]; then
            cd "$REPO_DIR"
            if git pull > /dev/null 2>&1; then
                echo -e "\nYour repository $REPO_DIR is successfully updated.\n"
            else
                echo -e "\nFailed to update the repository. Please check for issues.\n"
            fi
        else
            echo -e "\nDirectory $REPO_DIR exists but is not a Git repository.\n"
            return 1
        fi
    else
        if git clone "$REPO_URL" "$REPO_DIR" > /dev/null 2>&1; then
            echo -e "\nYour repository is successfully cloned. Check $REPO_DIR.\n"
        else
            echo -e "\nFailed to clone the repository. Please check the URL or your network connection.\n"
            return 1
        fi
    fi
}

git_checkout () {
    local BRANCH=$1
    if [ -n "$BRANCH" ]; then
        if git show-ref --verify --quiet "refs/heads/$BRANCH" || git show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
            git checkout "$BRANCH"

            if [ $? -eq 0 ]; then
                echo -e "\nSuccessfully switched to branch $BRANCH.\n"
            else
                echo -e "\nFailed to switch to branch $BRANCH. Please check if the branch name is correct.\n"
                return 1
            fi
        else
            echo -e "\nBranch $BRANCH does not exist.\n"
            return 1
        fi
    else
        echo -e "\nStaying on the current branch.\n"
    fi
}

# Function for obtaining the path for assembly
docker_build_path () {
    if [ -f "$DOCKERFILE_PATH" ]; then
        local BUILD_PATH=$(dirname "$DOCKERFILE_PATH")
        echo "$BUILD_PATH"
    elif [ -d "$DOCKERFILE_PATH" ]; then
        local BUILD_PATH=$(realpath "$DOCKERFILE_PATH")
        echo "$BUILD_PATH"
    else
        echo -e "\nError: Dockerfile not found at $DOCKERFILE_PATH\n" >&2
        exit 1
    fi
}

docker_build () {
    {
    docker build -t "$IMAGE_NAME" "$BUILD_PATH" > /dev/null 2>&1
    } &

    pid=$! # Get the PID of the installation process

    dynamic_progress_bar $pid # Call the dynamic progress bar function

    wait $pid  # Wait for the installation to finish

    if [ $? -eq 0 ]; then
        echo -e "\nDocker image successfully built from $DOCKERFILE_PATH.\n"
        echo -e "Container '$IMAGE_NAME' is built. Now you can run it.\n"
        return 0
    else
        echo -e "\nDocker build failed. Please check the Dockerfile and context.\n"
        return 1
    fi
}

stop_remove_container () {
    local CONTAINER_NAMES=("$@")

    # If there are no containers, display a message and exit
    if [ -z "$(docker ps -q)" ]; then
        echo -e "\nNo started containers. Start them by the 'docker run' command.\n"
        return 1
    fi

    # If the user has not entered anything, we use the last container that was running
    if [ -z "$CONTAINER_NAMES" ]; then
        CONTAINER_NAMES=$(docker ps -lq) # Get the ID of the last running container
    fi

    for NAME in "${CONTAINER_NAMES[@]}"; do
        # Find a container by name or ID
        local CONTAINER_ID=$(docker ps -aq --filter "name=$NAME")

        if [ -n "$CONTAINER_ID" ]; then  # If the container is found
            {
                docker stop "$CONTAINER_ID" > /dev/null 2>&1
                docker rm "$CONTAINER_ID" > /dev/null 2>&1
            } &
            pid=$!

            dynamic_progress_bar $pid

            wait $pid

            echo -e "\nStopped and removed existing container: $NAME\n"
        else
            echo -e "No existing container found for: $NAME\n"
        fi
    done
}


exposed_port() {
    if [ -f "$BUILD_PATH/Dockerfile" ]; then
        local EXPOSED_PORT=$(grep -i '^EXPOSE' "$BUILD_PATH/Dockerfile" | awk '{print $2}')
        if [ -n "$EXPOSED_PORT" ]; then
            echo "$EXPOSED_PORT"
            return 0
        else
            echo -e "\nNo port exposed in Dockerfile.\n"
            return 1
        fi
    else
        echo -e "\nDockerfile not found.\n"
        return 1
    fi
}

docker_container_name () {
    local CONTAINER_NAME=${1:-}

    # Генерация имени контейнера, исключающего недопустимые символы
    if [ -z "$CONTAINER_NAME" ]; then
        CONTAINER_NAME="${IMAGE_NAME//:/_}_$(date +%s)"
        echo "$CONTAINER_NAME"
        return 0
    fi
}

docker_run_detached () {
    local CONTAINER_NAME=$(docker_container_name "$1") # Передаем имя контейнера
    
    # Если пользователь не указал имя, оно должно быть сгенерировано
    if [ -z "$CONTAINER_NAME" ]; then
        CONTAINER_NAME="${IMAGE_NAME}_$(date +%s)"
        echo -e "\nNo name specified. Using generated name: $CONTAINER_NAME\n"
    fi

    if stop_remove_container; then
        docker run --name "$CONTAINER_NAME" -d "$IMAGE_NAME"
        if [ $? -eq 0 ]; then
            echo -e "\nContainer $CONTAINER_NAME started.\n" # Исправлено для вывода корректного имени контейнера
            return 0
        else
            echo -e "\nFailed to start container $CONTAINER_NAME.\n"
            return 1
        fi  
    else
        echo -e "\nUnable to start the image.\n"
        return 1
    fi
}

docker_run_detached_ports () {
    local EXPOSED_PORT=$(exposed_port)
    local CONTAINER_NAME=$(docker_container_name "$1")
    local HOST_PORT=${2:-"$EXPOSED_PORT"}

    # Проверка наличия портов
    if [ -z "$HOST_PORT" ] || [ -z "$EXPOSED_PORT" ]; then
        echo -e "\nError: No port specified and no EXPOSE directive found in Dockerfile.\n"
        return 1
    else
        if stop_remove_container "$CONTAINER_NAME"; then
            docker run --name "$CONTAINER_NAME" -d -p "$HOST_PORT":"$EXPOSED_PORT" "$IMAGE_NAME"
            if [ $? -eq 0 ]; then
                echo -e "\nContainer $CONTAINER_NAME started with ports mapped: $HOST_PORT -> $EXPOSED_PORT.\n"
                return 0
            else
                echo -e "\nFailed to start container $CONTAINER_NAME.\n"
                return 1
            fi
        else
            echo -e "\nUnable to start the image.\n"
            return 1
        fi
    fi
}


docker_run_detached_volume () {
    local CONTAINER_NAME=$(docker_container_name "$1")
    local HOST_DIR=$2
    local CONTAINER_DIR=$3

    # Проверка наличия директорий
    if [ -z "$HOST_DIR" ] || [ -z "$CONTAINER_DIR" ]; then
        echo -e "\nError: Both host directory and container directory must be specified.\n"
        return 1
    else
        if stop_remove_container "$CONTAINER_NAME"; then
            docker run --name "$CONTAINER_NAME" -d -v "$HOST_DIR":"$CONTAINER_DIR" "$IMAGE_NAME"
            if [ $? -eq 0 ]; then
                echo -e "\nContainer $CONTAINER_NAME started with volume $HOST_DIR mounted to $CONTAINER_DIR.\n"
                return 0
            else
                echo -e "\nFailed to start container $CONTAINER_NAME.\n"
                return 1
            fi
        else
            echo -e "\nUnable to start the image.\n"
            return 1
        fi
    fi    
}


# If the user wants to use own run command arguments
docker_custom_run () {
    local CONTAINER_NAME=$(docker_container_name "$1")
    local CUSTOM_ARGUMENTS=$2
    
    if [ -n "$CUSTOM_ARGUMENTS" ]; then  # Check that the arguments are passed
        docker run --name $CONTAINER_NAME $CUSTOM_ARGUMENTS "$IMAGE_NAME"
        if [ $? -eq 0 ]; then
            echo -e "\nContainer $IMAGE_NAME has started with custom arguments: $CUSTOM_ARGUMENTS.\n"
            return 0
        else
            echo -e "\nContainer $IMAGE_NAME failed to start. Check the correctness of the passed arguments.\n"
            return 1
        fi
    else
        echo -e "\nNo custom arguments were passed.\n"
        return 1
    fi
}

docker_custom_commands () {
    local CONTAINER_NAME=$(docker_container_name "$1")
    local CUSTOM_COMMAND=$2
    local CUSTOM_ARGUMENTS=${3:-}

    if [ -n "$CUSTOM_COMMAND" ]; then
        if docker --name "$CONTAINER_NAME" "$CUSTOM_COMMAND" $CUSTOM_ARGUMENTS "$IMAGE_NAME"; then
            return 0
        else
            echo -e "\nFailed to execute: docker $CUSTOM_COMMAND $CUSTOM_ARGUMENTS $IMAGE_NAME. Check the correctness of the command.\n"
            return 1
        fi
    else
        echo -e "\nNo custom command was provided.\n"
        return 1
    fi
}

docker_logs () {
    local CONTAINER_NAME=$(docker ps -q --filter ancestor="$IMAGE_NAME")

    if [ -z "$CONTAINER_NAME" ]; then
        echo -e "\nNo running container found for image $IMAGE_NAME.\n"
        return 1
    else
        # Includes timestamps for each line of the last 10 strings of logs
        echo "============================================="
        docker logs -t --tail 10 "$CONTAINER_NAME"
        echo "============================================="
        return 0
    fi
}

docker_images () {
    # Check if there are any Docker images
    if [ -z "$(docker images -q)" ]; then
        echo -e "\nNo images found. Build them from your Dockerfile.\n"
        return 1
    else
        # Display a list of all locally saved Docker images
        docker images
        echo ""
        return 0
    fi
}

docker_remove_images () {
    local FORCE=$1
    shift  # Remove the first argument (FORCE) from the list
    
    local IMAGE_NAMES=("$@")

    # Checking for Docker images
    if [ -z "$(docker images -q)" ]; then
        echo -e "\nNo images found. Build them from your Dockerfile.\n"
        return 1
    fi

    for NAME in "${IMAGE_NAMES[@]}"; do
        # Get image ID by image name
        local IMAGE_ID=$(docker images -q "$NAME")

        if [ -n "$IMAGE_ID" ]; then  # If the image is found
            # Verifying that the container is using the image
            if [ -n "$(docker ps -a -q --filter ancestor="$IMAGE_ID")" ]; then
                echo -e "\nCannot remove image $NAME (ID: $IMAGE_ID) because it is used by a container.\n"
            else
                case "$FORCE" in
                    Y|y)
                        docker rmi -f "$IMAGE_ID" > /dev/null 2>&1
                        ;;
                    N|n)
                        docker rmi "$IMAGE_ID" > /dev/null 2>&1
                        ;;
                    *)
                        echo "Invalid option for FORCE. Use Y or N."
                        ;;
                esac

                if [ $? -eq 0 ]; then
                    echo -e "\nRemoved existing image: $NAME (ID: $IMAGE_ID)\n"
                else
                    echo -e "\nFailed to remove image: $NAME (ID: $IMAGE_ID). Please check the image's usage status.\n"
                fi
            fi
        else
            echo -e "No existing image found for: $NAME\n"
        fi
    done
}


docker_started_containers () {
    # Check if there are any started Docker containers
    if [ -z "$(docker ps -q)" ]; then
        echo -e "\nNo started containers. Start them by the 'docker run' command.\n"
        return 1
    else
        # Display a list of all started Docker containers
        docker ps
        echo ""
        return 0
    fi
}

# Function to check for the presence of docker-compose.yml
docker_compose_file_check () {
    if [ -f "$DOCKER_COMPOSE_PATH" ]; then
        return 0
    else
        echo "No docker-compose.yml found in $BUILD_PATH"
        return 1
    fi
}

docker_compose_build () {
    if docker_compose_file_check; then
        docker compose -f "$DOCKER_COMPOSE_PATH" build
        if [ $? -eq 0 ]; then
            echo -e "\nDocker Compose build completed successfully.\n"
            return 0
        else
            echo -e "\nDocker Compose build failed.\n"
            return 1
        fi
    else
        echo -e "\nFailed to find docker-compose.yml for build.\n"
        return 1
    fi
}

docker_compose_up () {
    if docker_compose_file_check; then
    {
        docker compose -f "$DOCKER_COMPOSE_PATH" up -d
    } &
        pid=$!

        dynamic_progress_bar $pid

        wait $pid

        if [ $? -eq 0 ]; then
            echo -e "\nDocker Compose services have started successfully.\n"
            return 0
        else
            echo -e "\nFailed to start Docker Compose services.\n"
            return 1
        fi
    else
        echo -e "\nFailed to find docker-compose.yml for 'up' command.\n"
        return 1
    fi
}

docker_compose_down () {
    if docker_compose_file_check; then
    {
        docker compose -f "$DOCKER_COMPOSE_PATH" down
    } &
        pid=$!

        dynamic_progress_bar $pid

        wait $pid

        if [ $? -eq 0 ]; then
            echo -e "\nDocker Compose services have stopped successfully.\n"
            return 0
        else
            echo -e "\nFailed to stop Docker Compose services.\n"
            return 1
        fi
    else
        echo -e "\nFailed to find docker-compose.yml for 'down' command.\n"
        return 1
    fi
}

docker_compose_restart () {
    local SERVICES=("$@")

    if docker_compose_file_check; then
        local error_occurred=false
        for SERVICE in "${SERVICES[@]}"; do
            docker compose restart "$SERVICE"
            if [ $? -eq 0 ]; then
                echo -e "\nDocker Compose service '$SERVICE' restarted successfully.\n"
            else
                echo -e "\nFailed to restart Docker Compose service '$SERVICE'.\n"
                error_occurred=true
            fi
        done

        if [ "$error_occurred" = true ]; then
            return 1
        else
            return 0
        fi
    else
        echo -e "\nFailed to find docker-compose.yml for 'restart' command.\n"
        return 1
    fi
}

docker_compose_logs () {
    local SERVICES=("${@:-$SERVICES}")
    
    if [ ${#SERVICES[@]} -eq 0 ]; then
        # Check to see if there are any containers running
        if [ -z "$(docker compose ps -q)" ]; then
            echo -e "\nNo running services found. Start the services before checking logs.\n"
            return 1
        else
            # Show 10 strings of logs for all services
            docker compose logs -t --tail 10
        fi
    else
        for SERVICE in "${SERVICES[@]}"; do
            if docker compose ps -q "$SERVICE" > /dev/null 2>&1; then
                # Show 10 strings of logs for the specific service
                docker compose logs -t --tail 10 "$SERVICE"
            else
                echo -e "\nNo running service found for $SERVICE.\n"
            fi
        done
    fi
}

# Check if services are running and what state they are in
docker_compose_logs () {
    local SERVICES=("${@:-$SERVICES}")

    if [ ${#SERVICES[@]} -eq 0 ]; then
        # Show 10 lines of logs for all services
        docker compose logs -t --tail 10
    else
        for SERVICE in "${SERVICES[@]}"; do
            if docker compose ps -q "$SERVICE" > /dev/null 2>&1; then
                # Show 10 lines of logs for the specific service
                docker compose logs -t --tail 10 "$SERVICE"
            else
                echo -e "\nNo running service found for $SERVICE.\n"
            fi
        done
    fi
}


docker_compose_services () {
    # Display a list of all docker compose started services
    docker compose ps
    echo ""
}

# Removes stopped service containers
docker_compose_rm () {
    local SERVICES=("${@:-$SERVICES}")
    
    if [ ${#SERVICES[@]} -eq 0 ]; then
        # Remove all: This command removes all stopped service containers, including volumes.
        docker compose rm -f -s -v
    else
        for SERVICE in "${SERVICES[@]}"; do
            if docker compose ps -q "$SERVICE" > /dev/null 2>&1; then
                docker compose rm -f -s -v "$SERVICE"
                echo -e "\nRemoved stopped containers for $SERVICE.\n"
            else
                echo -e "\nNo stopped containers found for $SERVICE.\n"
            fi
        done
    fi          
}

# Pulls an image associated with a service defined in a compose.yaml file, but does not start containers based on those images
docker_compose_pull () {
    local SERVICES=("$@")

    if docker_compose_file_check; then
        if [ ${#SERVICES[@]} -eq 0 ]; then  # Правильная проверка размера массива
            docker compose pull -q
        else
            for SERVICE in "${SERVICES[@]}"; do
                docker compose pull -q "$SERVICE"
                if [ $? -eq 0 ]; then
                    echo -e "\nSuccessfully pulled image for $SERVICE.\n"
                else
                    echo -e "\nFailed to pull image for $SERVICE.\n"
                fi
            done
        fi 
    else
        echo -e "\ndocker-compose.yml file not found. Please check your setup.\n"
        return 1
    fi         
}

docker_compose_status () {
    local SERVICES=("${@:-$SERVICES}")
    
    if [ ${#SERVICES[@]} -eq 0 ]; then
        # Displays the running processes for all services
        docker compose top
    else
        for SERVICE in "${SERVICES[@]}"; do
            # Check if the service is defined in docker compose but not running
            if docker compose ps "$SERVICE" | grep -q "$SERVICE"; then
                # Check if the service is running
                if docker compose ps -q "$SERVICE" > /dev/null 2>&1; then
                    # Displays the running processes
                    docker compose top "$SERVICE"
                else
                    echo -e "\nService '$SERVICE' is defined but not currently running.\n"
                fi
            else
                echo -e "\nService '$SERVICE' is not found in docker compose.\n"
            fi
        done
    fi   
}

docker_compose_config () {
    if docker_compose_file_check; then
        if docker compose config > /dev/null 2>&1; then
            echo -e "\nYour docker-compose.yml is correct.\n"
            return 0
        else
            echo -e "\nYour docker-compose.yml is incorrect.\n"
            docker compose config
            return 1
        fi
    else
        echo -e "\ndocker-compose.yml file not found. Please check your setup.\n"
        return 1
    fi
}

# List of networks and volumes created by docker compose
docker_compose_networks_volumes () {
    echo "Listing Docker Compose networks:"
    if ! docker network ls --filter label=com.docker.compose.project --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"; then
        echo -e "\nFailed to list Docker Compose networks.\n"
        return 1
    fi

    echo -e "\nListing Docker Compose volumes:"
    if ! docker volume ls --filter label=com.docker.compose.project --format "table {{.Name}}\t{{.Driver}}\t{{.Mountpoint}}"; then
        echo -e "\nFailed to list Docker Compose volumes.\n"
        return 1
    fi
    echo ""
    return 0
}

docker_compose_custom () {
    local CUSTOM_COMMAND=$1
    local CUSTOM_ARGUMENTS=${2:-}

    if docker_compose_file_check; then
        if [ -n "$CUSTOM_COMMAND" ]; then  # Check that the command is passed
            case "$CUSTOM_COMMAND" in
                up|down)
                    if docker compose -f "$DOCKER_COMPOSE_PATH" "$CUSTOM_COMMAND" $CUSTOM_ARGUMENTS; then
                        echo -e "\ndocker compose command '$CUSTOM_COMMAND $CUSTOM_ARGUMENTS' executed successfully.\n"
                        return 0
                    else
                        echo -e "\nFailed to execute: docker compose $CUSTOM_COMMAND $CUSTOM_ARGUMENTS. Check the correctness of the command.\n"
                        return 1
                    fi
                    ;;
                build)
                    if docker compose -f "$DOCKER_COMPOSE_PATH" "$CUSTOM_COMMAND"; then
                        echo -e "\ndocker compose build executed successfully.\n"
                        return 0
                    else
                        echo -e "\nFailed to execute: docker compose $CUSTOM_COMMAND. Check the correctness of the command.\n"
                        return 1
                    fi
                    ;;
                *)
                    if docker compose $CUSTOM_COMMAND $CUSTOM_ARGUMENTS; then
                        echo -e "\ndocker compose command '$CUSTOM_COMMAND $CUSTOM_ARGUMENTS' executed successfully.\n"
                        return 0
                    else
                        echo -e "\nFailed to execute: docker compose $CUSTOM_COMMAND $CUSTOM_ARGUMENTS. Check the correctness of the command.\n"
                        return 1
                    fi
                    ;;
            esac
        else
            echo -e "\nNo custom command was provided.\n"
            return 1
        fi
    else
        echo -e "\ndocker-compose.yml file not found. Please check your setup.\n"
        return 1        
    fi
}

# Check if Docker is installed, if not, install it
if ! docker_check; then
    echo -e "\nDocker is not installed in your system. Installing...\n"
    docker_install
else
    echo -e "\nDocker is installed in your system. Proceeding...\n"
fi

# Check if Docker Compose is installed, if not, install it
if ! dockercompose_check; then
    echo -e "\ndocker compose is not installed in your system. Installing...\n"
    docker_compose_install
else
    echo -e "\ndocker compose is installed in your system. Proceeding...\n"
fi

# Check if Git is installed, if not, install it
if ! git_check; then
    echo -e "\nGIT is not installed in your system. Installing...\n"
    git_install
else
    echo -e "\nGIT is installed in your system. Proceeding...\n"
fi

# Ask the user to clone the repository first
echo -e "\nPlease provide the repository URL to clone: "
read -p "> " REPO_URL

# Check if the provided URL is a valid GitHub repository link
if [[ ! "$REPO_URL" =~ ^https://github.com/.+/.+(\.git)?$ ]]; then
    echo -e "\nThe link provided is not a valid GIT repository URL."
    echo -e "Provide the correct link (e.g., https://github.com/your_name/your_repository).\n"
    exit 1
fi

echo -e "\nPlease specify the directory where you want to clone the repository: "
read -p "> " REPO_DIR
echo ""

git_clone "$REPO_URL" "$REPO_DIR"
echo ""

# Switch to the needed branch
cd "$REPO_DIR"
echo -e "\nThe following branches are available in the repository:"
git branch -r

echo -e "\nPlease specify the branch you want to switch to (or press Enter to stay on the current branch): "
read -p "> " BRANCH

git_checkout "$BRANCH"

# Ask the user for the Dockerfile path after ensuring dependencies are installed
echo -e "\nPlease provide the path to your Dockerfile: "
read -p "> " DOCKERFILE_PATH
echo ""

# Validate Dockerfile path
if [ -z "$DOCKERFILE_PATH" ]; then
    echo "Error: DOCKERFILE_PATH is not set. Please provide the path to your Dockerfile."
    exit 1
fi

# Ask the user for the Dockerfile path after ensuring dependencies are installed
echo -e "\nPlease provide the TAG for your image: "
read -p "> " TAG

# Set TAG to 'latest' if not provided
if [ -z "$TAG" ]; then
    echo -e "\nWarning: TAG is not set. Using 'latest' as default."
    TAG="latest"
    echo ""
fi

# Check if yq is installed, if not, install it
if ! yq_check; then
    echo -e "\nyq is not installed in your system. Installing...\n"
    yq_install
else
    echo -e "\nyq is installed in your system. Proceeding...\n"
fi

# Initialize BUILD_PATH, IMAGE_NAME, and DOCKER_COMPOSE_PATH
BUILD_PATH=$(docker_build_path "$DOCKERFILE_PATH")
IMAGE_NAME=$(basename "$BUILD_PATH"):$TAG

DOCKER_COMPOSE_PATH="$BUILD_PATH/docker-compose.yml"
if [ ! -f "$DOCKER_COMPOSE_PATH" ]; then
    echo "No docker-compose.yml found in $BUILD_PATH"
    exit 1
fi

# Menu interface
while true; do
    echo "===================================================="
    echo "============= Docker Management Menu ==============="
    echo "===================================================="
    echo ""
    echo "==================================="
    echo "||     1 - Docker Management     ||"
    echo "==================================="
    echo ""
    echo "==================================="
    echo "||   2 - Launching Containers    ||"
    echo "==================================="
    echo ""
    echo "==================================="
    echo "|| 3 - Docker Compose Management ||"
    echo "==================================="
    echo ""
    echo "==================================="
    echo "||            4 - Exit           ||"
    echo "==================================="
    echo ""
    read -p "Select an option [1-4]: " MAIN_MENU_ANSW
    echo ""

    case "$MAIN_MENU_ANSW" in
        1)
            while true; do
                echo "===== Docker Image Management ====="
                echo ""
                echo "==================================="
                echo "||        1 - Docker build       ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||        2 - Docker images      ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||    3 - Docker remove images   ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||   4 - Docker custom command   ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||     5 - Back to main menu     ||"
                echo "==================================="
                echo ""
                read -p "Select an option [1-5]: " DOCKER_MNGMT_ANSW
                echo ""

                case "$DOCKER_MNGMT_ANSW" in
                    1)
                        docker_build
                        ;;
                    2)
                        docker_images
                        ;;
                    3)
                        docker_images # Список изображений

                        echo ""
                        echo -e "Would you like to force delete images? (Y/N)\n"
                        read -p "> " FORCE  

                        echo ""
                        echo -e "\nSpecify images to delete (e.g. my_app python_app etc...):\n"
                        read -p "> " IMAGES
                        IFS=' ' read -r -a IMAGE_NAMES <<< "$IMAGES"
                        echo ""                        

                        # Проверка на пустой ввод
                        if [ -z "$IMAGES" ]; then
                            echo -e "No images specified for deletion.\n"
                            break
                        fi

                        docker_remove_images "$FORCE" "${IMAGE_NAMES[@]}"
                        ;;
                    4)
                        echo ""
                        echo "Specify the custom Docker command: "
[I                        read -p "> " CUSTOM_COMMAND
                        echo ""

                        echo ""
                        echo "Specify a custom argument to the Docker command or press Enter to pass no arguments: "
                        read -p "> " CUSTOM_ARGUMENT
                        echo ""

                        docker_custom_commands "$CUSTOM_COMMAND" "$CUSTOM_ARGUMENT"
                        ;;
                    5)
                        break
                        ;;
                    *)  
                        echo -e "\nInvalid option. Please try again.\n"
                        ;;
                esac
            done
            ;;
        2)
            while true; do
                echo "======= Launching Containers ======"
                echo ""
                echo "==================================="
                echo "||    1 - Docker run Detached    ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||  2 - Docker run Detach&Ports  ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||  3 - Docker run Detach&Volume ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||    4 - Docker run (custom)    ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "|| 5 - Docker started containers ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||  6 - Stop & Remove container  ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||        7 - Docker logs        ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||     8 - Back to main menu     ||"
                echo "==================================="
                echo ""
                read -p "Select an option [1-8]: " CONTAINER_ANSW
                echo ""

                case "$CONTAINER_ANSW" in
                    1)
                        echo ""
                        echo "Specify the container name (e.g. 'my_app', 'python_project', etc...)"
                        read -p "> " CONTAINER_NAME

                        docker_run_detached "$CONTAINER_NAME"
                        ;;
                    2)
                        echo ""
                        echo "Specify the container name (e.g. 'my_app', 'python_project', etc...)"
                        read -p "> " CONTAINER_NAME
                        echo ""

                        echo "Specify the host port (e.g., 8080), or press Enter to use the exposed port from your Dockerfile."
                        read -p "> " HOST_PORT
                        echo ""

                        docker_run_detached_ports "$CONTAINER_NAME" "$HOST_PORT"
                        ;;
                    3)
                        echo ""
                        echo "Specify the container name (e.g. 'my_app', 'python_project', etc...)"
                        read -p "> " CONTAINER_NAME
                        echo ""

                        echo "Please, specify the host directory with the needed data: "
                        read -p "> " HOST_DIR
                        echo ""

                        echo ""
                        echo "Please, specify the container directory where the host directory will be mounted: "
                        read -p "> " CONTAINER_DIR
                        echo ""
                        
                        if [ -z "$HOST_DIR" ] || [ -z "$CONTAINER_DIR" ]; then
                            echo "Both repository URL and directory must be specified."
                            return 1
                        else
                            docker_run_detached_volume "$CONTAINER_NAME" "$HOST_DIR" "$CONTAINER_DIR"
                        fi                                               
                        ;;
                    4)
                        echo ""
                        echo "Specify the container name (e.g. 'my_app', 'python_project', etc...)"
                        read -p "> " CONTAINER_NAME
                        echo ""

                        echo "Specify the custom argument for Docker run command (e.g. -v -d -p): "
                        read -p "> " CUSTOM_ARGUMENT
                        echo ""

                        docker_custom_run "$CONTAINER_NAME" "$CUSTOM_ARGUMENT"
                        ;;
                    5)
                        echo ""
                        docker_started_containers # A list of the started containers
                        ;;
                    6)
                        echo ""
                        docker_started_containers # A list of the started containers

                        # Check to see if the action has been canceled
                        echo -e "\nAre you sure you want to remove a container(s)? (Y/N)"
                        read -p "> " CANCEL
                        case "$CANCEL" in
                            N|n)
                                echo -e "\nOperation cancelled.\n"
                                break  # Exit menu loop, return to main menu
                                ;;
                            Y|y)
                                echo -e "\nPlease specify the container(s) you want to remove (e.g. my_app1 app2 test_app etc.) \nOr press Enter to remove recently built one.\n"
                                read -p "> " REMOVE_CONTAINER_ANSW
                                
                                # Checking for blank input
                                if [ -z "$REMOVE_CONTAINER_ANSW" ]; then
                                    echo -e "\nNo container name provided. Using the most recently started container.\n"
                                    CONTAINER_NAMES=$(docker ps -lq) # Get the ID of the last running container
                                else
                                    IFS=' ' read -r -a CONTAINER_NAMES <<< "$REMOVE_CONTAINER_ANSW"
                                fi
                                
                                echo ""

                                stop_remove_container "${CONTAINER_NAMES[@]}"
                                ;;
                            *)
                                echo -e "\nInvalid option. Operation cancelled.\n"
                                break  # Exit menu loop, return to main menu
                                ;;
                        esac
                        ;;

                    7)
                        docker_logs
                        echo ""
                        ;;
                    8)
                        break
                        ;;
                    *)
                        echo -e "Invalid option. Please try again.\n"
                        ;;
                esac
            done
            ;;
        3)
            echo -e "\n========= Docker Compose Services ==========="
            yq e '.services | keys' docker-compose.yml
            echo -e "=============================================\n"

            echo "Specify the services you need to work with. (e.g. web app db...)"
            read -p "> " SERVICES_INPUT
            IFS=' ' read -r -a SERVICES <<< "$SERVICES_INPUT"
            echo ""

            if [ ${#SERVICES[@]} -eq 0 ]; then
                echo "No services specified. Please provide at least one service."
                return 1
            fi

            while true; do
                echo "==== Docker Compose Management ===="
                echo ""
                echo "==================================="
                echo "||   1 - Docker Compose build    ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||      2 - Docker Compose up    ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||    3 - Docker Compose down    ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||  4 - Docker Compose restart   ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||    5 - Docker Compose logs    ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||   6 - Docker Compose status   ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||  7 - Docker Compose services  ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||   8 - Docker Compose remove   ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||    9 - Docker Compose pull    ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||   10 - Docker Compose config  ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||    11 - Networks & Volumes    ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||   12 - Docker Compose custom  ||"
                echo "==================================="
                echo ""
                echo "==================================="
                echo "||    13 - Back to main menu     ||"
                echo "==================================="
                echo ""
                read -p "Select an option [1-13]: " DOCKER_COMPOSE_ANSW
                echo ""
                case "$DOCKER_COMPOSE_ANSW" in
                    1)
                        docker_compose_build
                        ;;
                    2)
                        docker_compose_up
                        ;;
                    3)
                        docker_compose_down
                        ;;
                    4)
                        docker_compose_restart "${SERVICES[@]}"
                        ;;
                    5)
                        docker_compose_logs "${SERVICES[@]}"
                        ;;
                    6)
                        docker_compose_status "${SERVICES[@]}"
                        ;;
                    7)
                        docker_compose_services
                        ;;
                    8)
                        docker_compose_rm
                        ;;
                    9)
                        docker_compose_pull "${SERVICES[@]}"
                        ;;
                    10)
                        docker_compose_config
                        ;;
                    11)
                        docker_compose_networks_volumes
                        ;;
                    12)
                        echo ""
                        echo "Specify a custom command to the docker compose: "
                        read -p "> " CUSTOM_COMMAND
                        echo ""

                        echo ""
                        echo "Specify a custom argument to the docker compose command or press Enter to pass no arguments: "
                        read -p "> " CUSTOM_ARGUMENT
                        echo ""

                        docker_compose_custom "$CUSTOM_COMMAND" "$CUSTOM_ARGUMENT"
                        ;;
                    13)
                        break
                        ;;
                    *)
                        echo -e "Invalid option. Please try again.\n"
                        ;;
                esac
            done
            ;;
        4)
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
