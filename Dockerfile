FROM nginx:mainline-alpine

LABEL maintainer="Florian Wartner <florian.wartner@deinebaustoffe.de>"

# INSTALL SOME SYSTEM PACKAGES.
RUN apk --update --no-cache add ca-certificates \
    bash supervisor git nano

ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# IMAGE ARGUMENTS WITH DEFAULTS.

ARG PHP_VERSION=7.4
ARG ALPINE_VERSION=3.9
ARG NGINX_HTTP_PORT=80
ARG NGINX_HTTPS_PORT=443

RUN apk --update add ca-certificates
    
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    echo "@php https://dl.bintray.com/php-alpine/v3.9/php-${PHP_VERSION}" >> /etc/apk/repositories

RUN apk add --no-cache --virtual .build-deps \
    autoconf \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    perl-dev \
    luajit-dev \
    sqlite

# INSTALL PHP AND SOME EXTENSIONS. SEE: https://github.com/codecasts/php-alpine
RUN apk add --no-cache --update php7-dev@php \
    php-fpm@php \
    php7-pear@php \
    libmcrypt-dev \
    freetype-dev \
    libpng-dev \
    libpq \
    php@php \
    php-openssl@php \
    php-gd@php \
    php-pdo@php \
    php-redis@php \
    php-iconv@php \
    php-mbstring@php \
    php-sockets@php \
    php-phar@php \
    php-exif@php \
    php-mysqlnd@php \
    php-session@php \
    php-dom@php \
    php-ctype@php \
    php-posix@php \
    php-zlib@php \
    php-json@php \
    php-bcmath@php \
    php-curl@php \
    php-pcntl@php \
    php-xml@php \
    php-zip@php \
    php-xmlreader@php \
    php-soap@php \
    php-amqp@php \
    php-pdo_mysql@php \
    php-pdo_sqlite@php

RUN pecl channel-update pear.php.net \
    && ln -s /usr/bin/php7 /usr/bin/php \
    && pecl install mcrypt

# CONFIGURE WEB SERVER.
RUN mkdir -p /var/www && \
    mkdir -p /run/php && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/nginx/sites-enabled && \
    mkdir -p /etc/nginx/sites-available && \
    rm /etc/nginx/nginx.conf && \
    rm /etc/php7/php-fpm.d/www.conf && \
    rm /etc/php7/php.ini

# INSTALL COMPOSER.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" \
    && composer global require hirak/prestissimo

# Cleanup dev dependencies
RUN apk del -f .build-deps

# ADD START SCRIPT, SUPERVISOR CONFIG, NGINX CONFIG AND RUN SCRIPTS.
ADD start.sh /start.sh
ADD config/supervisor/supervisord.conf /etc/supervisord.conf
RUN mkdir /etc/supervisor/
ADD config/nginx/nginx.conf /etc/nginx/nginx.conf
ADD config/nginx/site.conf /etc/nginx/sites-available/default.conf
ADD config/php/php.ini /etc/php7/php.ini
ADD config/php-fpm/www.conf /etc/php7/php-fpm.d/www.conf
RUN chmod 755 /start.sh

# EXPOSE PORTS!
EXPOSE ${NGINX_HTTPS_PORT} ${NGINX_HTTP_PORT}

# SET THE WORK DIRECTORY.
WORKDIR /var/www

# KICKSTART!
CMD ["/start.sh"]
