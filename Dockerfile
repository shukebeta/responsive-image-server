FROM nginx:stable-alpine AS production-stage

RUN set -x \
    && apk add --no-cache --virtual .cert-deps openssl \
    && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/ \
    && apk del .cert-deps \
    && NGINX_VERSION=$(nginx -v 2>&1 | grep -o '[0-9.]\+') \
    && ALPINE_VERSION=$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release) \
    && PKG_RELEASE=$(wget -qO- https://nginx.org/packages/alpine/v${ALPINE_VERSION}/main/x86_64/ | grep -o "nginx-module-image-filter-${NGINX_VERSION}-r[0-9]*" | head -1 | sed 's/.*-r\([0-9]*\).*/\1/') \
    && apk add -X "https://nginx.org/packages/alpine/v${ALPINE_VERSION}/main" --no-cache nginx-module-image-filter=${NGINX_VERSION}-r${PKG_RELEASE}

RUN sed -i '1i\load_module modules/ngx_http_image_filter_module.so;' /etc/nginx/nginx.conf

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]

