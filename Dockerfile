FROM php:8.3-apache

# 1. تثبيت الحزم الأساسية وحزم الـ SSL والشهادات (مهمة جداً لـ TiDB)
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

# 6. تثبيت حزم لارافل للـ Production
RUN composer install --no-interaction --optimize-autoloader --no-dev

# 7. إعطاء الصلاحيات المناسبة لمجلدات الكاش والتخزين
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 8. ضبط منفذ Apache ديناميكياً ليتناسب مع متغير PORT الخاص بـ Railway
# (هذا السطر يمنع الـ 502 نهائياً)
CMD sed -i "s/80/\${PORT}/g" /etc/apache2/sites-available/*.conf /etc/apache2/ports.conf && apache2-foreground