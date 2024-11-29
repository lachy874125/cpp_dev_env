# INSTRUCTIONS:
# To build the docker container and pass in a public ssh key for remote access (replace with your own public key filepath):
# docker build --build-arg PUBLIC_KEY="$(cat /path/to/your/public/key.pub)" -t cpp_dev .
# 
# To create the docker container, map the ssh port, attach/create a volume, and start it in the background:
# docker run -d -p 2222:22 --name container_name --mount type=volume,src=volume_name,dst=/home/dev/vol cpp_dev
#
# To start the existing container and open the terminal:
# docker start --attach --interactive cpp_dev bash
#
# To exit:
# exit

FROM ubuntu:24.04
SHELL ["/bin/bash", "-c"]
LABEL Maintainer="LachlanTaylor"
LABEL Description="Ubuntu development environment for C++"

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    cmake \
    g++ \
    git \
    openssh-server \
    sudo
# - ca-certificates is used for github authentication
# - cmake is used to generate build systems for C++ projects
# - g++ is used to compile C++ code
# - git is used for version control
# - openssh-server is used for accessing the container via ssh
# - sudo is used for administrator privileges

# Add a non-root user
ARG USERNAME=dev
RUN useradd --create-home --shell /bin/bash $USERNAME

# Grant sudo privileges to the user
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up SSH for the dev user
RUN mkdir -p /home/$USERNAME/.ssh && chmod 700 /home/$USERNAME/.ssh

# Use build argument to add a public key for SSH authentication
ARG PUBLIC_KEY
RUN echo "$PUBLIC_KEY" > /home/$USERNAME/.ssh/authorized_keys && \
    chmod 600 /home/$USERNAME/.ssh/authorized_keys && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

# Create the SSH server runtime directory
# Disable password authentication
# Modifies the SSH PAM configuration to avoid potential login issues in container environments
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# Expose SSH port
EXPOSE 22

# Set volume directory and permissions
ARG VOLUME_DIR=/home/$USERNAME/vol
RUN mkdir -p $VOLUME_DIR && chown -R $USERNAME:$USERNAME $VOLUME_DIR

# Set working directory
WORKDIR /home/$USERNAME

# Start SSH daemon
CMD ["/usr/sbin/sshd", "-D"]