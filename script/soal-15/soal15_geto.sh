cat << 'EOF' > /root/soal15_geto.sh
#!/bin/bash
apt-get update && apt-get install -y nginx curl

cat << 'CONF' > /etc/nginx/sites-available/default
upstream api_cluster {
    server 192.219.4.6:80 weight=3 max_fails=2 fail_timeout=5s; # nanami
    server 192.219.4.7:80 weight=1 max_fails=2 fail_timeout=5s; # todo
    server 192.219.4.8:80 backup;                               # kirara
}

server {
    listen 80 default_server;

    set_real_ip_from 192.219.1.4;
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 2s;
        proxy_read_timeout 3s;
    }
}
CONF

nginx -t && service nginx restart
EOF
chmod +x /root/soal15_geto.sh
bash /root/soal15_geto.sh

