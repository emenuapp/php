# Build
FROM php:8.1-fpm as build

# Install system packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libzip-dev \
    cron

# Install xdebug for code coverage
RUN pecl install xdebug \
  && docker-php-ext-enable xdebug

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd pdo_mysql zip bcmath pcntl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy file upload config
RUN touch /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 20M;" >> /usr/local/etc/php/conf.d/uploads.ini

# Increase php memory limit
# Copy file upload config
RUN touch /usr/local/etc/php/conf.d/memory.ini \
    && echo "memory_limit = 4G;" >> /usr/local/etc/php/conf.d/memory.ini

# Install AWS CLI
WORKDIR /var/tmp
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
