# hydrator

hydrator = nginx + dehyrated + Let's Encrypt.

hydrator uses [dehydrated](https://github.com/lukas2511/dehydrated) (a Lets's Encrypt ACME client) and nginx to automate creation and renewal of SSL Certificates.

# Read this!

**Please note that you should use the staging URL when experimenting with this project to not hit letsencrypts [rate limits](https://letsencrypt.org/docs/rate-limits/).** See [https://github.com/lukas2511/dehydrated/tree/master/docs/staging.md](https://github.com/lukas2511/dehydrated/tree/master/docs/staging.md).


# tl;dr

```
mkdir -p /tmp/path/to/nginx/conf.d/
cat  << EOF > /tmp/path/to/nginx/conf.d/default.conf
server {
    listen              443 ssl;
    server_name         your.domain.com;
    ssl_certificate     /etc/dehydrated/certs/your.domain.com/fullchain.pem;
    ssl_certificate_key /etc/dehydrated/certs/your.domain.com/privkey.pem;
    location / {
        root   /var/www/hydrated;
        index  index.html index.htm;
    }
}
EOF
docker create --name hydrator -v /tmp/path/to/nginx/conf.d/:/etc/nginx/conf.d/:ro -p 443:443 -p 80:80 lelandsindt/hydrator
docker start hydrator
```

.... ok now go back and read the following.

[https://letsencrypt.org/docs/](https://letsencrypt.org/docs/)
[https://github.com/lukas2511/dehydrated](https://github.com/lukas2511/dehydrated)

# SSL Offload Proxy

hydrator can be used to build an SSL Offload Proxy adding an encrypted front end to an un-encrypted application. 

in this example we have two back end servers 192.168.100.100 and 192.168.100.101 that are listening on port 80.

```
mkdir -p /tmp/path/to/nginx/conf.d/
cat << EOF > /tmp/path/to/nginx/conf.d/default.conf
tream backends {
    server 192.168.100.100:80;
    server 192.168.100.101:80;
}
server {
    listen              443 ssl;
    server_name         your.domain.com;
    ssl_certificate     /etc/dehydrated/certs/your.domain.com/fullchain.pem;
    ssl_certificate_key /etc/dehydrated/certs/your.domain.com/privkey.pem;
    ssl_session_cache   builtin:1000  shared:SSL:10m;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $host:443;
        proxy_set_header X-Forwarded-Port 443;
        proxy_set_header X-Forwarded-Proto "https";
        proxy_read_timeout 300;
        proxy_pass http://backends/;
    }
}
EOF
docker create --name hydrator -v /tmp/path/to/nginx/conf.d/:/etc/nginx/conf.d/:ro -p 443:443 -p 80:80 lelandsindt/hydrator
docker start hydrator
```

# Presisting Config and Certs

dehydrated stores all of its config in /etc/dehydrated/ adding `-v /tmp/path/to/dehydrated/:/etc/dehydrated/`  will presist dehydrated's configuration files and the certs it generates outside of the container.  

You will also need to create a [config](https://github.com/lukas2511/dehydrated/blob/master/docs/examples/config) file for dehydrated to use. At a minimum you should configure your email address.

```
mkdir -p /tmp/path/to/dehydrated/
cat << EOF > /tmp/path/to/dehydrated/config
CONTACT_EMAIL=you@your.domain.com
EOF
```

# Domains  

## server_name

for every instance of `serer_name` found in /etc/nginx/conf.d/*.conf hydrator will call `dehydrated --domain your.domain.com` 

## domains.txt

hydrator will instruct dehydrated to use [domains.txt](https://github.com/lukas2511/dehydrated/blob/master/docs/domains_txt.md) if it is found at `/etc/dehydrated/domains.txt`

