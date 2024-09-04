FROM nginx:stable-alpine AS production-stage

ENV NGINX_VERSION=1.26.0
ENV PKG_RELEASE=1

# Install necessary packages, including certbot and cron
RUN set -x \
    && apk add --no-cache --virtual .cert-deps openssl \
    && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/ \
    && apk del .cert-deps \
    && apk add -X "https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache \
       nginx-module-image-filter=${NGINX_VERSION}-r${PKG_RELEASE} \
    && apk add --no-cache certbot certbot-nginx \
    && apk add --no-cache busybox-suid # install the crond application

# Load the image filter module
RUN sed -i '1i\load_module modules/ngx_http_image_filter_module.so;' /etc/nginx/nginx.conf

# Copy script to handle certbot
COPY ./init-letsencrypt.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-letsencrypt.sh

# Copy cron job configuration
COPY ./crontab /etc/crontabs/root

# Expose ports
EXPOSE 80 443

# Start Nginx and cron
CMD ["/bin/sh", "-c", "/usr/local/bin/init-letsencrypt.sh && crond"]
