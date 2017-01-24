# hydrator

hydrator = nginx + dehyrated + Let's Encrypt.

hydrator uses dehydrated (a Lets's Encrpt ACME client) and nginx to automate creation and renewal of SSL Certificates.

# tl;dr

```
mkdir -p __/path/to/nginx/conf.d/__
cat  << EOF > __/path/to/nginx/conf.d/__default.conf
server {
    listen              443 ssl;
    server_name       __your.domain.com__;
    ssl_certificate     /etc/dehydrated/certs/__your.domain.com__/fullchain.pem;
    ssl_certificate_key /etc/dehydrated/certs/__your.domain.com__/privkey.pem;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}
EOF
docker pull lelandsindt/hydrator
docker create --name hydrator -v __/path/to/nginx/conf.d/__:/etc/nginx/conf.d/:ro -p 443:443 -p 80:80 lelandsindt/hydrator
docker start hydrator
```
