cat << 'EOF' > /root/soal14_frontend.sh
#!/bin/bash
apt-get update && apt-get install -y nginx php-fpm

service php8.4-fpm start

mkdir -p /var/www/html
cat << 'PHP' > /var/www/html/index.php
<?php
echo "Frontend Worker: " . gethostname() . "\n";
?>
PHP

cat << 'CONF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    server_name jujutsu.k16.com www.jujutsu.k16.com;
    root /var/www/html;
    index index.php index.html;

    allow 192.219.1.4;
    deny all;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
CONF

nginx -t && service nginx restart
EOF
chmod +x /root/soal14_frontend.sh
bash /root/soal14_frontend.sh

