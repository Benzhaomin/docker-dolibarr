ARG php_fpm_image

FROM $php_fpm_image

LABEL maintainer="Monogramm Maintainers <opensource at monogramm dot io>"

RUN echo -e "http://nl.alpinelinux.org/alpine/v3.11/main\nhttp://nl.alpinelinux.org/alpine/v3.11/community" > /etc/apk/repositories

# Install the packages we need
RUN set -ex; \
    apk add --no-cache \
        icu-libs \
        imagemagick \
        libpq \
        libpng \
        libjpeg-turbo \
        libzip \
        rsync \
        ssmtp \
        shadow \
        libmemcached-libs \
        zlib \
    ; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        autoconf \
        curl-dev \
        freetype-dev \
        gcc \
        g++ \
        icu-dev \
        imagemagick-dev \
        imagemagick-libs \
        libjpeg-turbo-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libpng-dev \
        libtool \
        libxml2-dev \
        libzip-dev \
        make \
        oniguruma-dev \
        openssl-dev \
        postgresql-dev \
        postgresql-libs \
        unzip \
        zlib-dev \
    ; \
    docker-php-ext-configure gd --with-freetype; \
    docker-php-ext-install -j$(nproc) \
        calendar \
        gd \
        intl \
        mbstring \
        opcache \
        pdo \
        pdo_pgsql \
        pgsql \
        soap \
        zip \
    ; \
    pecl install imagick; \
    docker-php-ext-enable imagick; \
    pecl install memcached; \
    docker-php-ext-enable memcached; \
    apk --purge del .build-deps;

COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Build time env var
ARG dolibarr_version
ENV DOLI_VERSION=${dolibarr_version}

# Get Dolibarr
ADD https://github.com/Dolibarr/dolibarr/archive/${DOLI_VERSION}.zip /tmp/dolibarr.zip

# Prepare folders
RUN set -ex; \
    mkdir -p /var/www/documents; \
    chown -R www-data:root /var/www; \
    chmod -R g=u /var/www; \
    mkdir -p /tmp/dolibarr; \
    unzip -q /tmp/dolibarr.zip -d /tmp/dolibarr; \
    rm /tmp/dolibarr.zip; \
    mkdir -p /usr/src/dolibarr; \
    cp -r /tmp/dolibarr/dolibarr-${DOLI_VERSION}/* /usr/src/dolibarr; \
    rm -rf /tmp/dolibarr; \
    chmod +x /usr/src/dolibarr/scripts/*

# Runtime env var
ENV DOLI_AUTO_CONFIGURE=1 \
    DOLI_DB_TYPE=mysqli \
    DOLI_DB_HOST= \
    DOLI_DB_PORT=3306 \
    DOLI_DB_USER=dolibarr \
    DOLI_DB_PASSWORD='' \
    DOLI_DB_NAME=dolibarr \
    DOLI_DB_PREFIX=llx_ \
    DOLI_DB_CHARACTER_SET=utf8 \
    DOLI_DB_COLLATION=utf8_unicode_ci \
    DOLI_DB_ROOT_LOGIN='' \
    DOLI_DB_ROOT_PASSWORD='' \
    DOLI_ADMIN_LOGIN=admin \
    DOLI_MODULES='' \
    DOLI_URL_ROOT='http://localhost' \
    DOLI_AUTH=dolibarr \
    DOLI_HTTPS=0 \
    DOLI_PROD=0 \
    DOLI_NO_CSRF_CHECK=0 \
    WWW_USER_ID=82 \
    WWW_GROUP_ID=82 \
    PHP_INI_DATE_TIMEZONE='UTC' \
    PHP_MEMORY_LIMIT=256M \
    PHP_MAX_UPLOAD=20M \
    PHP_MAX_EXECUTION_TIME=300 \
    PHP_DISPLAY_ERRORS='On'

VOLUME /var/www/html /var/www/documents /var/www/scripts

COPY entrypoint.sh /
RUN set -ex; \
    chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
