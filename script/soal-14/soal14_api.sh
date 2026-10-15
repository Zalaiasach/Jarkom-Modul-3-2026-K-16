cat << 'EOF' > /root/soal14_api.sh
#!/bin/bash
apt-get update && apt-get install -y nginx php-fpm php-mysql

service php8.4-fpm start

mkdir -p /var/www/api
cat << 'PHP' > /var/www/api/index.php
<?php
$client_ip = $_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'];
$hostname = gethostname();

$conn = new mysqli("192.219.4.9", "shibuya_user", "shibuya123", "db_shibuya_k16");
if (!$conn->connect_error) {
    $stmt = $conn->prepare("INSERT INTO request_logs (client_ip, worker_hostname) VALUES (?, ?)");
    $stmt->bind_param("ss", $client_ip, $hostname);
    $stmt->execute();
    $stmt->close();
    $conn->close();
}

header("Content-Type: application/json");
echo json_encode([
    "status" => "success",
    "worker" => $hostname,
    "client_ip" => $client_ip
]) . "\n";
?>
PHP

cat << 'CONF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    root /var/www/api;
    index index.php;

    allow 192.219.4.3;
    allow 127.0.0.1;
    deny all;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_param HTTP_X_REAL_IP $http_x_real_ip;
        fastcgi_param HTTP_X_FORWARDED_FOR $http_x_forwarded_for;
    }
}
CONF

nginx -t && service nginx restart
EOF
chmod +x /root/soal14_api.sh
bash /root/soal14_api.sh

