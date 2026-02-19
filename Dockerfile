FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev \
    nodejs npm

# Enable Apache rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy project
COPY . .

# Install PHP deps
RUN composer install --no-dev --optimize-autoloader

# Install Node deps & build frontend
RUN npm install && npm run build

# Laravel permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Apache config
COPY ./docker/apache.conf /etc/apache2/sites-available/000-default.conf

CMD php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache && \
    apache2-foreground