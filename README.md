# hydrator

hydrator = nginx + dehyrated + Let's Encrypt.

hydrator uses dehydrated (a Lets's Encrpt ACME client) and nginx to automate creation and renewal of SSL Certificates.

# tl;dr

```
mkdir -p /path/to/nginx/conf.d/
cat  << EOF > /path/to/nginx/conf.d/default.conf
server {
    listen              443 ssl;
    server_name         your.domain.com;
    ssl_certificate     /etc/dehydrated/certs/your.domain.com/fullchain.pem;
    ssl_certificate_key /etc/dehydrated/certs/your.domain.com/privkey.pem;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}
EOF
docker pull lelandsindt/hydrator
docker create --name hydrator -v /path/to/nginx/conf.d/:/etc/nginx/conf.d/:ro -p 443:443 -p 80:80 lelandsindt/hydrator
docker start hydrator
```
