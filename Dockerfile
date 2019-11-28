# vim:set ft=dockerfile:

FROM ubuntu:18.04
MAINTAINER Alex Kosenko <alexander.kosenko@vrpconsulting.com>
ENV LC_ALL C.UTF-8
ENV PHP_VERSION="7.3"

#Fix slow repo
#RUN sed -i 's/archive.ubuntu.com/mirror.datacenter.by/g' /etc/apt/sources.list
# Mkdir folder
RUN mkdir /var/log/php7-fpm/ /run/php/ /var/run/sshd
# Intall packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common apt-utils apt-transport-https && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    php$PHP_VERSION \
    php$PHP_VERSION-cli \
    php$PHP_VERSION-apcu \
    php$PHP_VERSION-opcache \
    php$PHP_VERSION-readline \
    php$PHP_VERSION-common \
    php$PHP_VERSION-gd \
    php$PHP_VERSION-imagick \
    php$PHP_VERSION-mysql \
    php$PHP_VERSION-curl \
    php$PHP_VERSION-intl \
    php$PHP_VERSION-xsl \
    php$PHP_VERSION-mbstring \
    php$PHP_VERSION-zip \
    php$PHP_VERSION-bcmath \
    php$PHP_VERSION-iconv \
    php$PHP_VERSION-json \
    php$PHP_VERSION-fpm \
    php$PHP_VERSION-mysql \
    php$PHP_VERSION-soap \
    php$PHP_VERSION-xml \
    php-json-schema \
    ssmtp \
    git \
    mailutils mc inetutils-ping unzip bzip2 libpng-dev net-tools openssh-server supervisor nano curl sudo mysql-client nginx redis-tools htop vim build-essential make dnsutils

#ADD ./config/ssmtp.conf /etc/ssmtp/ssmtp.conf
ADD ./config/supervisord.conf /etc/supervisord.conf
#
RUN sed -i 's|%$PHP_VERSION%|'$PHP_VERSION'|g'  /etc/supervisord.conf

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer

RUN echo 'www-data:hugTeybvootduc' | chpasswd && usermod -s /bin/bash www-data
RUN echo "sudo -H -u www-data -s" >> /root/.bashrc

# Install nodejs + grunt
RUN curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
RUN sudo bash nodesource_setup.sh
RUN apt-get install -y nodejs
RUN npm install -g grunt-cli

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

RUN mkdir -p /var/www && chown www-data:www-data /var/www/ && usermod -a -G sudo www-data
RUN echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN rm /etc/nginx/sites-available/default && rm /etc/nginx/sites-enabled/default

# www.conf
RUN sed -i 's/listen\s*=.*/listen = 0.0.0.0:9000/g' /etc/php/$PHP_VERSION/fpm/pool.d/www.conf
# PHP options
RUN sed -i 's/memory_limit\s*=.*/memory_limit=2048M/g' /etc/php/$PHP_VERSION/cli/php.ini
RUN sed -i 's/memory_limit\s*=.*/memory_limit=2048M/g' /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -i 's/max_execution_time\s*=.*/max_execution_time=3600/g' /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -i 's/max_execution_time\s*=.*/max_execution_time=3600/g' /etc/php/$PHP_VERSION/cli/php.ini
RUN sed -i 's/max_input_time\s*=.*/max_input_time=1200/g' /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -i 's/max_input_time\s*=.*/max_input_time=1200/g' /etc/php/$PHP_VERSION/cli/php.ini
RUN sed -i 's/max_input_vars\s*=.*/max_input_vars=30000/g' /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -i 's/max_input_vars\s*=.*/max_input_vars=30000/g' /etc/php/$PHP_VERSION/cli/php.ini
RUN sed -i 's/max_file_uploads\s*=.*/max_file_uploads=1000/g' /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -i 's/max_file_uploads\s*=.*/max_file_uploads=1000/g' /etc/php/$PHP_VERSION/cli/php.ini
RUN sed -i 's/default_socket_timeout\s*=.*/default_socket_timeout=1200/g' /etc/php/$PHP_VERSION/cli/php.ini
RUN sed -i 's/default_socket_timeout\s*=.*/default_socket_timeout=1200/g' /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -i 's/upload_max_filesize\s*=.*/upload_max_filesize=512M/g' /etc/php/$PHP_VERSION/cli/php.ini
RUN sed -i 's/upload_max_filesize\s*=.*/upload_max_filesize=512M/g' /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -i 's/post_max_size\s*=.*/post_max_size=512M/g' /etc/php/$PHP_VERSION/cli/php.ini
RUN sed -i 's/post_max_size\s*=.*/post_max_size=512M/g' /etc/php/$PHP_VERSION/fpm/php.ini
RUN sed -i 's/display_errors\s*=.*/display_errors=On/g' /etc/php/$PHP_VERSION/cli/php.ini
RUN sed -i 's/display_errors\s*=.*/display_errors=On/g' /etc/php/$PHP_VERSION/fpm/php.ini

# Fix slow ubuntu repoRUN sed -i 's/mirror.datacenter.by/archive.ubuntu.com/g' /etc/apt/sources.list
#RUN sed -i 's/mirror.datacenter.by/archive.ubuntu.com/g' /etc/apt/sources.list
#Clear space
RUN sudo apt-get clean
RUN rm -rf /var/lib/apt/lists/*

RUN echo "Host *" >> /etc/ssh/ssh_config
RUN echo "ForwardAgent yes" >> /etc/ssh/ssh_config
RUN echo "HashKnownHosts no" >> /etc/ssh/ssh_config
RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

WORKDIR /var/www
USER root

ENTRYPOINT [ "supervisord" ]
