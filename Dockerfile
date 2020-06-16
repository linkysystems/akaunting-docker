FROM php:7.4-apache

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libzip-dev \
    imagemagick \
    libmcrypt-dev \
    libpng-dev \
    libpq-dev \
    libxrender1 \
    locales \
    openssh-client \
    patch \
    unzip \
    zlib1g-dev \
    zip \
    wget \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

COPY ./conf.d/locale.gen /etc/
RUN locale-gen

RUN docker-php-ext-install \
    gd \
    bcmath \
    pcntl \
    pdo \
    pdo_pgsql \
    pdo_mysql \
    zip

RUN a2enmod rewrite

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
  && rm /etc/apache2/sites-enabled/000-default.conf

COPY ./conf.d/php.ini /usr/local/etc/php/conf.d/akaunting.ini
COPY ./conf.d/akaunting.conf /etc/apache2/sites-enabled/akaunting.conf

COPY ./conf.d/docker-php-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php-entrypoint

RUN wget -O akaunting.zip "https://akaunting.com/download.php?version=latest&utm_source=docker&utm_campaign=developers" \
    && mkdir -p /var/www/html \
    && unzip akaunting.zip -d /var/www/html \
    && rm akaunting.zip
