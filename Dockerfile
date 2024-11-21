# INSTRUCTIONS:
# To build the docker image:
# docker build -t cpp_dev .
# 
# To create the docker container, attach/create a volume, start it and open the terminal:
# docker run --name container_name -it --mount type=volume,src=volume_name,dst=/home/dev/vol cpp_dev
#
# To start the existing container and open the terminal:
# docker start --attach --interactive cpp_dev
#
# To exit:
# exit

FROM ubuntu:24.04
SHELL ["/bin/bash", "-c"]
LABEL Maintainer="LachlanTaylor"
LABEL Description="Ubuntu development environment for C++"

# 'apt-get update' must be && with 'apt-get install' to ensure package versions remain up-to-date when
# appending packages. If apt-get update is on its own line it is cached by Docker and will not be updated.
# '--no-install-recommends' excludes recommended packages to keep containers lightweight and grant
# more control over installed dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
ca-certificates \
cmake \
g++ \
git \
sudo
# - ca-certificates is used for github authentication
# - cmake is used to generate build systems for C++ projects
# - g++ is used to compile C++ code
# - git is used for version control
# - sudo is used for administrator privileges

# Add a non-root user to adhere to security best-practices.
ARG USERNAME=dev
RUN useradd --create-home --shell /bin/bash $USERNAME

# Grant sudo privileges to the user by appending a line in /etc/sudoers
# echo translation: $USERNAME can: on all hosts, as any target user, execute all commands without a password
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Become the user
USER $USERNAME

# As the user, make the directory we will map the volume to, as the user, so it has proper permissions
ARG VOLUME_DIR=/home/$USERNAME/vol
RUN mkdir -p $VOLUMES_DIR

WORKDIR /home/$USERNAME