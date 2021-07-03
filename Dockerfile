FROM php:8-cli AS composer

ENV COMPOSER_HOME=/tmp

RUN apt-get update && \
    apt-get install -y \
        git \
        unzip \
        curl

COPY --from=composer:2.1 /usr/bin/composer /usr/bin/composer
COPY ./docker/composer/php.ini /usr/local/etc/php/conf.d/custom.ini

ENTRYPOINT ["composer"]
CMD ["/bin/true"]

###############################################################################

FROM composer AS vendors

WORKDIR /srv/app
RUN mkdir /srv/app/vendor
COPY composer.json composer.lock symfony.lock ./

RUN composer install \
        --no-scripts \
        --no-interaction \
        --no-ansi \
        --prefer-dist \
        --optimize-autoloader \
        --no-dev

###############################################################################

FROM php:8-apache AS apache

ARG USER=www-data

RUN apt-get update && \
    apt-get install -y \
        libicu-dev \
        libonig-dev \
        libpq-dev && \
    docker-php-ext-install \
        bcmath \
        intl \
        pdo_pgsql && \
    mv /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./docker/apache/apache2.conf /etc/apache2/apache2.conf
COPY ./docker/apache/ports.conf /etc/apache2/ports.conf
COPY ./docker/apache/app.conf /etc/apache2/sites-available/000-default.conf

RUN mkdir /srv/app && chown $USER /srv/app
USER $USER
WORKDIR /srv/app

COPY . .
COPY --from=vendors /srv/app/vendor vendor

###############################################################################

FROM php:8-cli AS php

ARG USER=www-data

RUN apt-get update && \
    apt-get install -y \
        libicu-dev \
        libonig-dev \
        libpq-dev && \
    docker-php-ext-install \
        bcmath \
        intl \
        pdo_pgsql && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /srv/app && chown $USER /srv/app
USER $USER
WORKDIR /srv/app

COPY . .
COPY --from=vendors /srv/app/vendor vendor
