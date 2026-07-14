FROM php:8.3-fpm-alpine

# تثبيت الحزم الأساسية وخادم Nginx والشهادات
RUN apk add --no-cache nginx supervisor curl libpng-dev libxml2-dev zip unzip git oniguruma-dev ca-certificates openssl

# تثبيت إضافات PHP
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# تثبيت Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/html
COPY . .

# تثبيت حزم لارافل للإنتاج وتنظيف الكاش
RUN composer install --no-interaction --optimize-autoloader --no-dev \
    && php artisan config:clear || true

# ضبط الصلاحيات
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# إعداد ملف تشغيل Nginx المباشر المتوافق مع Railway PORT
CMD sh -c "echo 'server { listen '${PORT:-80}'; root /var/www/html/public; index index.php; location / { try_files \$uri \$uri/ /index.php?\$query_string; } location ~ \.php$ { fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; include fastcgi_params; fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; } }' > /etc/nginx/http.d/default.conf && php-fpm -D && nginx -g 'daemon off;'