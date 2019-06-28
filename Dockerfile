FROM php:7.2-apache
LABEL maintainer="Emeric Lebon <emeric.lebon@madelink.fr>"
LABEL description="This is an image of a Moodle runtime made for running on non root environments like Openshift."

ARG MOODLE_VERSION=3.6.4
ENV UPLOAD_MAX_FILESIZE=50M
ENV PHP_LOG_ERRORS=on
ENV PHP_ERROR_OUTPUT=stderr

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /var/www/html

RUN apt-get update \
    && apt-get -qq install graphviz aspell ghostscript libpspell-dev libpng-dev libicu-dev libxml2-dev libldap2-dev sudo netcat unzip \
    && docker-php-ext-install -j$(nproc) pspell gd intl xml xmlrpc ldap zip soap mbstring mysqli opcache \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && curl -L https://github.com/moodle/moodle/archive/v${MOODLE_VERSION}.tar.gz | tar xz --strip=1 \
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && mkdir -p /moodledata /var/local/cache \
    && chown -R www-data:www-data /moodledata \
    && chmod -R 777 /moodledata /var/local/cache \
    && chmod -R 0755 /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && mkdir /docker-entrypoint.d

COPY config.php /var/www/html/
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY custom-php.ini $PHP_INI_DIR/conf.d/

RUN chown -R www-data:www-data /var/www/html \
    && sed -i 's/80/8080/g' /etc/apache2/sites-enabled/000-default.conf \
    && sed -i 's/443/8443/g' /etc/apache2/sites-enabled/000-default.conf \
    && sed -i 's/80/8080/g' /etc/apache2/ports.conf \
    && sed -i 's/443/8443/g' /etc/apache2/ports.conf \
    && sed -i 's/www-data:x:33:33:www-data:\/var\/www:\/usr\/sbin\/nologin/www-data:x:33:33:www-data:\/var\/www:\/bin\/sh/g' /etc/passwd

EXPOSE 8080

USER www-data

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["apachectl", "-e", "info", "-D", "FOREGROUND"]