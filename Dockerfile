# vim:set ft=dockerfile:

FROM ubuntu:18.04
MAINTAINER Alex Korotysh <alex.korotysh@ewave.com>
ENV LC_ALL C.UTF-8
ENV PHP_VERSION="7.2"

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

ADD ./config/ssmtp.conf /etc/ssmtp/ssmtp.conf
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