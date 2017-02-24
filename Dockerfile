FROM ubuntu:16.04

MAINTAINER Eduardo Bizarro <edbizarro@gmail.com>

# Set correct environment variables
ENV HOME /root

# Ensure UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
RUN locale-gen en_US.UTF-8

# MYSQL ROOT PASSWORD
ARG MYSQL_ROOT_PASS=root    

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common \
    python-software-properties \
    build-essential \
    curl \
    git \
    unzip \
    mcrypt \
    wget \
    openssl \
    autoconf \
    g++ \
    make \
    --no-install-recommends && rm -r /var/lib/apt/lists/* \
    && apt-get --purge autoremove -y

# OpenSSL
RUN mkdir -p /usr/local/openssl/include/openssl/ && \
    ln -s /usr/include/openssl/evp.h /usr/local/openssl/include/openssl/evp.h && \
    mkdir -p /usr/local/openssl/lib/ && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.a /usr/local/openssl/lib/libssl.a && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/local/openssl/lib/

# NODE JS
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
    apt-get install nodejs -qq && \
    npm install -g gulp
    
# YARN
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# MYSQL
# /usr/bin/mysqld_safe
RUN bash -c 'debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password password $MYSQL_ROOT_PASS"' && \
		bash -c 'debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password_again password $MYSQL_ROOT_PASS"' && \
		DEBIAN_FRONTEND=noninteractive apt-get update && \
		DEBIAN_FRONTEND=noninteractive apt-get install -qqy mysql-server-5.7
		
# PHP Extensions
RUN add-apt-repository -y ppa:ondrej/php && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y -qq php-pear php7.0-dev php7.0-mcrypt php7.0-zip php7.0-xml php7.0-mbstring php7.0-curl php7.0-json php7.0-mysql php7.0-tokenizer php7.0-cli php7.0-imap && \
    apt-get remove --purge php5 php5-common

# these packages are needed if you want to use wkhtmltopdf
RUN apt-get install -y -qq libxext6 libxrender1 libfontconfig1

# MONGO extension
RUN pecl install mongodb && \
    echo "extension=mongodb.so" > /etc/php/7.0/cli/conf.d/20-mongodb.ini && \
    echo "extension=mongodb.so" > /etc/php/7.0/mods-available/mongodb.ini

# Run xdebug installation.
RUN wget --no-check-certificate https://xdebug.org/files/xdebug-2.5.0.tgz && \
    tar -xzf xdebug-2.5.0.tgz && \
    rm xdebug-2.5.0.tgz && \
    cd xdebug-2.5.0 && \
    phpize && \
    ./configure --enable-xdebug && \
    make && \
    cp modules/xdebug.so /usr/lib/. && \
    echo 'zend_extension="/usr/lib/xdebug.so"' > /etc/php/7.0/cli/conf.d/20-xdebug.ini && \
    echo 'xdebug.remote_enable=1' >> /etc/php/7.0/cli/conf.d/20-xdebug.ini

# Time Zone
RUN echo "date.timezone=America/Sao_Paulo" > /etc/php/7.0/cli/conf.d/date_timezone.ini

VOLUME /root/composer

# Environmental Variables
ENV COMPOSER_HOME /root/composer

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Goto temporary directory.
WORKDIR /tmp

# Run phpunit installation.
RUN composer selfupdate && \
    composer global require hirak/prestissimo --prefer-dist --no-interaction && \
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit && \
    rm -rf /root/.composer/cache/*

RUN apt-get clean -y && \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
