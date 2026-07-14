FROM php:8.3-apache

# 1. تثبيت الحزم الأساسية وحزم الـ SSL والشهادات
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    ca-certificates \
    openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. تثبيت وتفعيل إضافات PHP المطلوبة
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# 3. تثبيت Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# 4. تفعيل مود الـ Rewrite في Apache وضبط مجلد الـ Public لـ Laravel
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 5. تحديد مجلد العمل ونسخ الملفات
WORKDIR /var/www/html
COPY . /var/www/html

# 6. تثبيت حزم لارافل للـ Production وتنظيف أي كاش محلي قديم فوراً
RUN composer install --no-interaction --optimize-autoloader --no-dev

# 7. إعطاء الصلاحيات الكاملة والمناسبة لمجلدات الكاش والتخزين
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 8. ضبط منفذ Apache وتجهيز البيئة (تنظيف الكاش وتوليد المفاتيح وتشغيل المايجريشن) قبل الإقلاع
ENV APACHE_PORT=80
RUN sed -i 's/Listen 80/Listen ${PORT}/g' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:${PORT}>/g' /etc/apache2/sites-available/*.conf

CMD php artisan config:clear && \
    php artisan route:clear && \
    php artisan cache:clear && \
    php artisan view:clear && \
    php artisan migrate --force && \
    php artisan passport:keys --force || true && \
    apache2-foreground