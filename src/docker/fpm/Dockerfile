FROM ubuntu:20.04 AS build
WORKDIR /root

ENV DEBIAN_FRONTEND noninteractive

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV CPPFLAGS="$CFLAGS"
ENV LDFLAGS="-Wl,-O1 -pie"

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    pkg-config \
    build-essential \
    autoconf \
    bison \
    re2c \
    curl \
    libcurl4-openssl-dev \
    autoconf \
    libxml2 \
    libxml2-dev \
    libonig5 \
    libonig-dev \
    openssl \
    libssl-dev \
    libsodium23 \
    libsodium-dev \
    libicu66 \
    libicu-dev \
    libzip5 \
    libzip-dev \
    zlib1g \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY php-7.4.5.tar.gz /root/
RUN mkdir php-7.4.5 && tar -xzf /root/php-7.4.5.tar.gz -C php-7.4.5 --strip-components 1

WORKDIR /root/php-7.4.5
RUN ./buildconf --force
RUN ./configure \
    --with-fpm-user=php \
    --with-fpm-group=php \
    --prefix=/usr \
    --sysconfdir=/etc/php \
    --localstatedir=/var \
    --mandir=/usr/share/man \
    --with-config-file-path=/etc/php \
    --with-config-file-scan-dir=/etc/php/conf.d \
    --disable-all \
    --disable-cgi \
    --disable-phpdbg \
    --enable-fpm \
    --enable-opcache=shared \
    --with-iconv=shared \
    --enable-json=shared \
    --enable-ctype=shared \
    --enable-tokenizer=shared \
    --enable-simplexml=shared \
    --enable-mbstring=shared \
    --enable-xml=shared \
    --with-curl=shared \
    --enable-intl=shared \
    --with-libxml=shared \
    --with-openssl=shared \
    --enable-phar=shared \
    --enable-filter=shared \
    --with-zlib=shared \
    --with-zip=shared \
    --enable-dom=shared \
    --enable-session=shared

RUN make -j$(nproc --all)
RUN make install
RUN mkdir -p /etc/php
RUN cp php.ini-production /etc/php/php.ini
RUN mv /etc/php/php-fpm.conf.default /etc/php/php-fpm.conf
RUN mv /etc/php/php-fpm.d/www.conf.default /etc/php/php-fpm.d/www.conf
RUN sed -i -e 's/^listen = .*/listen = 0.0.0.0:9000/g' /etc/php/php-fpm.d/www.conf
RUN rm -f /usr/lib/php/extensions/*/*.a

FROM ubuntu:20.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    iproute2 \
    curl \
    libxml2 \
    libonig5 \
    libsodium23 \
    libicu66 \
    openssl \
    libzip5 \
    zlib1g \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/php/
RUN mkdir -p /usr/lib/php/extensions
RUN mkdir -p /etc/php/conf.d

COPY --from=build /usr/bin/php /usr/bin/
COPY --from=build /usr/sbin/php-fpm /usr/sbin/
COPY --from=build /etc/php /etc/php
COPY --from=build /usr/lib/php/extensions/ /usr/lib/php/extensions

RUN for ext in /usr/lib/php/extensions/*/*.so ; do filename=$(echo ${ext##*/}| cut -d'.' -f 1) ; \
    echo "extension=$filename" >> "/etc/php/conf.d/00-$filename.ini" ; done && \
    sed -i -e 's/extension/zend_extension/' /etc/php/conf.d/00-opcache.ini

# Create phpfpm user/group
RUN groupadd -g 82 php
RUN useradd -u 82 -c "PHP Fast Process Manager" -g 82 -r -m -d /var/lib/php php

# Install composer and init Symfony demo project
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && rm -f composer-setup.php \
    && php composer.phar create-project symfony/skeleton /srv/demo \
    && rm -f composer.phar

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

WORKDIR /srv
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm", "-F"]
