# C++ Development Environment in Docker

A lightweight and portable Docker-based development environment for C++ programming. I use this setup for creating consistent, isolated environments for development and testing.

## Instructions
Before starting, ensure that Docker is installed on the host machine.
### Build the Docker Image

Run the following command to build the Docker image:

```docker
docker build -t cpp_dev .
```

### Create and Start a Docker Container

To create a new container, attach/create a volume, and start it:

```docker
docker run --name container_name -it --mount type=volume,src=volume_name,dst=/home/dev/vol cpp_dev
```

If the volume doesn't exist, Docker will create it automatically.

### Start an Existing Container

If the container already exists, you can start and attach to it with:

```docker
docker start --attach --interactive cpp_dev
```

### Exit the Container

To exit the container, type:

```docker
exit
```

## Notes
- The container is started as a non-root user `dev` with `sudo` access for security and convenience.
- A volume directory `/home/dev/vol` is created and owned by the `dev` user. When creating a new container, if any volumes are to be mounted, they should be mounted here otherwise the user will not have the necessary permissions within the volume.

## Optional: Editing Code with VS Code
I use Visual Studio Code as my code editor. To edit within the container and utilize the container's programming resources (e.g., compilers, libraries):
1. Install Dev Containers extension for VS Code.
2. Ensure a container has been created and is running.
3. Open the Dev Containers extension tab in VS Code
4. Right click on the running container and select 'Attach in New Window'.