#!/usr/bin/env bash


deploy_cert() {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"
    echo "nginx -s reload -c /etc/nginx/nginx.conf"
    nginx -s reload -c /etc/nginx/nginx.conf
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_cert)$ ]]; then
  "$HANDLER" "$@"
fi
