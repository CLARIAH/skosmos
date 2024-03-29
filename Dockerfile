FROM library/php:7.3-apache

# set skosmos release version and download link
ARG version=v2.17
ARG SKOSMOS_TARGZ_RELEASE_URL=https://github.com/NatLibFi/Skosmos/archive/${version}.tar.gz

# general server setup and locale
RUN apt-get update && \
  apt-get -y install gettext locales curl unzip vim git libicu-dev libxslt-dev && \
  for locale in en_GB en_US fi_FI fr_FR sv_SE; do \
    echo "${locale}.UTF-8 UTF-8" >> /etc/locale.gen ; \
  done && \
  locale-gen

# config apache2
RUN a2enmod rewrite
RUN a2enmod expires
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install Skosmos
RUN rm -rf /var/www/html/* && curl -L --output skosmos.tar.gz ${SKOSMOS_TARGZ_RELEASE_URL} && \
    tar -zxvf skosmos.tar.gz -C /var/www/html/ --strip-components=1 && \
	rm -rf /Skosmos* /skosmos.tar.gz

# install composer required php packs
RUN docker-php-ext-install intl
RUN docker-php-ext-install xsl
RUN docker-php-ext-install gettext

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Skosmos dependencies
RUN /usr/local/bin/composer install --no-dev --no-interaction

# Configure Skosmos
COPY entrypoint.sh /var/www/
COPY config-docker-compose.ttl /var/www/html/
ENTRYPOINT ["/var/www/entrypoint.sh"]