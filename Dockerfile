FROM php:8.2-apache


RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd


COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf


RUN sed -i 's/Listen 80/Listen 7860/' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:7860>/' /etc/apache2/sites-available/*.conf


WORKDIR /var/www/html
COPY . /var/www/html

RUN composer install --no-interaction --optimize-autoloader --no-dev


RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache


EXPOSE 7860
