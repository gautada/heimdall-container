ARG ALPINE_VERSION=latest

FROM docker.io/gautada/alpine:$ALPINE_VERSION as src

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
ARG CONTAINER_VERSION="2.6.1"
ARG HEIMDALL_SERVER_VERSION="$CONTAINER_VERSION"
ARG HEIMDALL_SERVER_BRANCH=v"$HEIMDALL_SERVER_VERSION"

# RUN /sbin/apk add --no-cache git gradle maven openjdk17-jdk ttf-dejavu
# graphviz

RUN git config --global advice.detachedHead false
RUN git clone --branch $HEIMDALL_SERVER_BRANCH --depth 1 https://github.com/linuxserver/Heimdall.git heimdall

# ╭―
# │                                                                         
# │ STAGE: container                                                        
# │                                                                         
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# FROM docker.io/gautada/alpine:$ALPINE_VERSION

# ╭―
# │ METADATA           
# ╰――――――――――――――――――――
LABEL source="https://github.com/gautada/heimdall-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A container for heimdall application dashboard"

# ╭―
# │ USER
# ╰――――――――――――――――――――
ARG USER=heimdall
RUN /usr/sbin/usermod -l $USER alpine
RUN /usr/sbin/usermod -d /home/$USER -m $USER
RUN /usr/sbin/groupmod -n $USER alpine
RUN /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭―
# │ PRIVILEGES
# ╰――――――――――――――――――――
COPY privileges /etc/container/privileges

# ╭―
# │ BACKUP
# ╰――――――――――――――――――――
# RUN /bin/rm -f /etc/periodic/hourly/container-backup
# COPY backup /etc/container/backup

# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
COPY entrypoint /etc/container/entrypoint

# ╭―
# │ APPLICATION        
# ╰――――――――――――――――――――


# ╭―
# │ CONFIGURATION
# ╰――――――――――――――――――――
RUN chown -R $USER:$USER /home/$USER 
# USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /home/$USER


