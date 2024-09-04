FROM nginx:stable-alpine AS production-stage

# Dynamically fetch the latest version and package release
RUN set -x \
    && apk add --no-cache --virtual .cert-deps openssl \
    && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/ \
    && apk del .cert-deps \
    && NGINX_VERSION=$(nginx -v 2>&1 | grep -o '[0-9.]\+') \
    && PKG_RELEASE=$(wget -qO- https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main/x86_64/ | grep -oP "nginx-module-image-filter-${NGINX_VERSION}-r\K[0-9]+" | head -1) \
    && apk add -X "https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache nginx-module-image-filter=${NGINX_VERSION}-r${PKG_RELEASE}

RUN sed -i '1i\load_module modules/ngx_http_image_filter_module.so;' /etc/nginx/nginx.conf

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
