cat << 'EOF' > /root/soal16_gojo.sh
#!/bin/bash
apt-get update && apt-get install -y nginx curl

mkdir -p /var/cache/nginx

cat << 'CONF' > /etc/nginx/sites-available/default
upstream frontend_cluster {
    server 192.219.4.4:80;
    server 192.219.4.5:80;
}

proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=WEB_CACHE:10m max_size=100m inactive=60m use_temp_path=off;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

server {
    listen 80 default_server;
    server_name jujutsu.k16.com www.jujutsu.k16.com;

    location /api {
        limit_req zone=api_limit nodelay;
        limit_req_status 503;

        proxy_pass http://192.219.4.3/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        proxy_pass http://frontend_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_cache WEB_CACHE;
        proxy_cache_valid 200 302 10m;
        add_header X-Cache-Status $upstream_cache_status;
    }
}
CONF

nginx -t && service nginx restart
EOF
chmod +x /root/soal16_gojo.sh
bash /root/soal16_gojo.sh

