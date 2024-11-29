# C++ Linux-based development environment in Docker

A lightweight and portable Docker-based development environment for C++ programming. I use this setup for creating consistent, isolated Linux environments for development and testing.

## Features
- Non-root user `dev` with sudo privileges for secure and flexible operations.
- Persistent storage through Docker volumes.
- SSH access to the container for remote development.
- Pre-installed tools: cmake, g++, git, and more.

## Instructions
Before starting, ensure that Docker is installed on the host machine.
### Generate an SSH key (if you don't already have one)
1. Run the following command in a terminal:
```bash
ssh-keygen
```
2. When prompted, enter the desired name of your key (e.g. `docker_key`).
3. Optionally set a password.
4. Your public and private keys will be stored in `~/.ssh/` as `docker_key.pub` and `docker_key` respectively.
### Build the Docker image

Run the following command to build the Docker image:

```bash
docker build --build-arg PUBLIC_KEY="$(cat /path/to/your/public/key.pub)" -t cpp_dev .
```
- Note: `$(cat ...)` just outputs the contents of your public key so you can also just copy this in to the command manually if preferred.
### Create and start a Docker container

To create a docker container, map the SSH port to 2222 (or any other port of your choosing), attach/create a volume, and start it in the background:

```bash
docker run -d -p 2222:22 --name container_name --mount type=volume,src=volume_name,dst=/home/dev/vol cpp_dev
```

- Note: if the volume doesn't exist, Docker will create it automatically.

### Attach to a running detached container

If the container is running in a detached state (no interactive terminal), you can attach to it with:

```bash
docker exec -it cpp_dev bash
```

### Start a stopped container

If the container already exists but isn't running, you can start and attach to it with:

```bash
docker start --attach --interactive cpp_dev
```


### Exit the Container

To exit the container, type:

```docker
exit
```

## Optional: Editing code with VS Code
I use Visual Studio Code installed on my Windows host as my code editor. Normally VS Code on Windows doesn't have access to the contents of the container. However, this can be overcome by connecting to the container via SSH. To edit within the container and utilize the container's programming resources (e.g., compilers, libraries):
1. Install the Remote - SSH extension for VS Code.
2. In VS Code, click "F1" to open the Command Palette.
3. Type and select: "Remote-SSH: Open SSH Configuration File..."
4. Choose the SSH configuration file to update (I use the one in my user folder)
4. Enter the following:
```
Host docker-container
    HostName localhost
    User root
    Port 2222
```
5. Save and close the SSH configuration file.
6. Ensure the container is running and the SSH port has been mapped.
7. Open the Remote Explorer tab in VS Code. Ensure the dropdown is set to "Remotes (Tunnels/SSH)".
8. The docker container should now be showing in the list as `docker-container`. Right-click and connect.