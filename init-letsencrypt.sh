#!/bin/sh

domains=(${DOMAINS//,/ })
email=$EMAIL
rsa_key_size=4096
data_path="/etc/letsencrypt"
staging=$STAGING

if [ ! -e "$data_path" ]; then
  mkdir -p "$data_path"
fi

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  wget -qO "$data_path/conf/options-ssl-nginx.conf" https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf
  wget -qO "$data_path/conf/ssl-dhparams.pem" https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem
  echo
fi

echo "### Requesting Let's Encrypt certificate for $domains ..."
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

if [ $staging != "0" ]; then staging_arg="--test-cert"; fi

certbot --nginx \
  $staging_arg \
  $domain_args \
  --email $email --rsa-key-size $rsa_key_size --agree-tos --no-eff-email

echo "### Reloading Nginx ..."
nginx -s reload
