ARG ALPINE_VERSION=latest

FROM docker.io/gautada/alpine:$ALPINE_VERSION

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
ARG CONTAINER_VERSION="2.6.1"
ARG HEIMDALL_SERVER_VERSION="$CONTAINER_VERSION"
ARG HEIMDALL_SERVER_BRANCH=v"$HEIMDALL_SERVER_VERSION"

WORKDIR /home/heimdall
RUN git config --global advice.detachedHead false
RUN git clone --branch $HEIMDALL_SERVER_BRANCH --depth 1 https://github.com/linuxserver/Heimdall.git www

RUN /sbin/apk add --no-cache nginx php83 php83-ctype php83-curl php83-dom php83-fileinfo php83-mbstring php83-openssl php83-pdo php83-session php83-tokenizer php83-xml php83-pdo_sqlite php83-zip php83-fpm

RUN /bin/rm /etc/nginx/http.d/*
COPY http.conf /etc/nginx/http.d/http.conf
COPY nginx.conf /etc/nginx/nginx.conf
# COPY php.ini /etc/php83/php.ini
COPY www.conf /etc/php83/php-fpm.d/www.conf
# COPY php-fpm.conf /etc/php83/php-fpm.conf
RUN /bin/touch /var/log/php83/error.log /var/log/php83/www.access.log
RUN /bin/chmod 777 -R /var/log/php83

COPY app.sqlite /mnt/volumes/container/app.sqlite
RUN chown $USER:$USER /mnt/volumes/container/app.sqlite
RUN ln -svf /mnt/volumes/container/app.sqlite /home/$USER/www/database/app.sqlite
COPY env.conf /home/$USER/www/.env
# ╭―
# │ CONFIGURATION
# ╰――――――――――――――――――――
RUN /bin/chown -R $USER:$USER /home/$USER
USER $USER
WORKDIR /home/$USER
# /usr/bin/php83 artisan key:generate
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /home/$USER


