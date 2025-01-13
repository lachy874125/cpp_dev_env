# C/C++ Linux-based development environment in Docker

A Dockerfile for creating consistent, isolated, lightweight, and portable Linux development environments for C/C++ development and testing. Preferred IDEs installed on the host machine can be used within the containers either natively or via SSH connection. This means an editor such as VS Code, installed on the host, can point to a directory within the container and develop within it as if it were installed within the container. It can therefore make use of the container's libraries, compilers, and other resources. For IDE's without native container support, the containers can optionally be built with supplied SSH keys to enable external SSH connection to the container.

## Features
- Pre-installed development tools: cmake, g++, git, and more (feel free to add your own).
- Persistent storage through Docker volumes.
- Non-root user `dev` with sudo privileges for secure and flexible operations.
- Optional SSH access to the container for development with preferred IDEs.

## Instructions for containers without SSH access
Before starting, ensure that Docker is installed on the host machine.

### Build the Docker image
Run the following command to build the Docker image:
```bash
docker build --target base -t cpp_dev .
```
### Create and start a Docker container
To create a docker container, attach/create a volume, start it and attach a terminal:
```bash
docker run -it --name container_name --mount type=volume,src=volume_name,dst=/home/dev/vol cpp_dev bash
```
- If the volume doesn't exist, Docker will create it automatically.

### Exit the Container

To exit the container, type:

```docker
exit
```
### Start an exited container

If the container already exists but has been exited (revealed by `docker ps -a`), you can restart and attach to it with:

```bash
docker start -ai cpp_dev
```

### Developing with VS Code
1. Install the Dev Containers extension for VS Code.
2. Ensure the container is running.
3. Open the Remote Explorer tab in VS Code. Ensure the dropdown is set to "Dev Containers".
4. The docker container should now be showing in the list. Right-click and connect.

Note: if you are running Docker directly within WSL (not Docker Desktop on Windows), you have to open VS Code from WSL instead of Windows, otherwise the container will not appear. To do this, in WSL simply run `code`.


## Instructions for containers with SSH access
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
docker build --secret id=ssh_key,src=/path/to/your/public/key.pub -t cpp_dev .
```
- This will allow docker to build with your supplied SSH public key without it becoming part of any image layers. This would otherwise be a security concern.

### Create and start a Docker container

To create a docker container, map the SSH port to port 2222 (or any other port of your choosing), attach/create a volume, and start it in the background:

```bash
docker run -d -p 2222:22 --name container_name --mount type=volume,src=volume_name,dst=/home/dev/vol cpp_dev
```

### Attach to the running detached container

```bash
docker exec -it cpp_dev bash
```
- The reason we start the SSH-enabled container in a detached state and then attach a terminal after is because if we do a `docker run -it ... cpp_dev bash` the final command of the Dockerfile which starts the SSH daemon will be overwritten with `bash` and won't start.

### Start an exited container

If the container already exists but has been exited (revealed by `docker ps -a`), you can restart it with:

```bash
docker start cpp_dev
```
- You can then attach a terminal to it with the previously mentioned exec command.

### Developing with VS Code
1. Install the Remote - SSH extension for VS Code.
2. In VS Code, click "F1" to open the Command Palette.
3. Type and select: "Remote-SSH: Open SSH Configuration File..."
4. Choose the SSH configuration file to update (I use the one in my user folder)
4. Enter the following:
```
Host name-of-your-choice
    HostName localhost
    User dev
    Port 2222
    IdentityFile /path/to/your/public/key.pub
```
5. Save and close the SSH configuration file.
6. Ensure the container is running and the SSH port has been mapped.
7. Open the Remote Explorer tab in VS Code. Ensure the dropdown is set to "Remotes (Tunnels/SSH)".
8. The docker container should now be showing in the list as `name-of-your-choice`. Right-click and connect.
- Note: if you map another container to the same port, often you will be denied access when attempting to connect to it via SSH. This is because there is a `known_hosts` file in the same directory as your SSH keys that stores a list of pairs of network addresses and host SSH keys. SSH expects the same key as before but different containers will have different keys so it blocks the connection. This is to prevent man-in-the-middle attacks. To get around this, either delete the old entries in `known_hosts` if you don't want to connect to those containers anymore. Then you should be able to connect and `known_hosts` will be updated automatically. Otherwise, you can simply add an entry to enable SSH connections to both containers. To find the new containers SSH key run the following command and manually create a new entry in `known_hosts`.
```bash
cat /etc/ssh/ssh_host_ecdsa_key.pub
# or
cat /etc/ssh/ssh_host_rsa_key.pub
```