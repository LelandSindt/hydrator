FROM nginx
RUN apt-get update && apt-get install -y \
    curl \
    openssl \
    supervisor \
    && rm -rf /var/lib/apt/lists/*
ADD https://raw.githubusercontent.com/lukas2511/dehydrated/master/dehydrated /usr/bin/dehydrated
ADD /usr/bin/hook.sh /usr/bin/hook.sh
ADD /usr/bin/hydrator /usr/bin/hydrator
ADD etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD etc/dehydrated/config /etc/dehydrated/config
ADD etc/nginx-80/* /etc/nginx-80/
RUN chmod 700 -v /usr/bin/dehydrated /usr/bin/hydrator /usr/bin/hook.sh && \
    mkdir -p /var/www/dehydrated/ && \
    touch /var/www/dehydrated/nginx && \
    sed -i 's/listen       80;/listen       443;/' /etc/nginx/conf.d/default.conf && \
    chown 0:0 -Rv /usr/bin/dehydrated /usr/bin/hydrator /var/www/dehydrated /etc/supervisor /etc/nginx-80 /etc/dehydrated
EXPOSE 80 443
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
