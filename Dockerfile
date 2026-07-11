FROM php:8.3-apache

# 1. تثبيت الأدوات الأساسية والملحقات التي يحتاجها لارافل
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# 2. تحميل أداة Composer داخل السيرفر تلقائياً
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 🛠️ [إضافة جديدة]: تفعيل صلاحيات السوبر يوزر لـ Composer لتجنب أي توقف في السيرفر السحابي
ENV COMPOSER_ALLOW_SUPERUSER=1

# 3. تفعيل مود الـ Rewrite في أباتشي وتوجيهه لمجلد public
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 4. نسخ ملفات كود مشروعك (بدون الـ vendor) إلى السيرفر
WORKDIR /var/www/html
COPY . /var/www/html

# 5. أمر تثبيت حزم الـ vendor على السيرفر مباشرة وبأعلى سرعة
RUN composer install --no-interaction --optimize-autoloader --no-dev

# 6. إعطاء الصلاحيات اللازمة للمجلدات
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
