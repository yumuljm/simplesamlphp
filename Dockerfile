FROM php:8.3-apache

ARG SSP_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
      libicu-dev curl ca-certificates \
    && docker-php-ext-install intl opcache \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    curl -fsSL -o /tmp/ssp.tar.gz \
      "https://github.com/simplesamlphp/simplesamlphp/releases/download/v${SSP_VERSION}/simplesamlphp-${SSP_VERSION}-full.tar.gz"; \
    mkdir -p /var/simplesamlphp; \
    tar -xzf /tmp/ssp.tar.gz --strip-components=1 -C /var/simplesamlphp; \
    rm /tmp/ssp.tar.gz; \
    mkdir -p /var/simplesamlphp/log /var/simplesamlphp/data /var/cache/simplesamlphp; \
    chown -R www-data:www-data /var/simplesamlphp/log /var/simplesamlphp/data /var/cache/simplesamlphp

RUN printf '%s\n' \
  'Alias /simplesaml /var/simplesamlphp/public' \
  '<Directory /var/simplesamlphp/public>' \
  '  Require all granted' \
  '</Directory>' > /etc/apache2/conf-available/simplesaml.conf \
  && a2enconf simplesaml

EXPOSE 80
