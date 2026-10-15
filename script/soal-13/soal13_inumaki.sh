cat << 'EOF' > /root/soal13_inumaki.sh
#!/bin/bash
apt-get update && apt-get install -y mariadb-server mariadb-client

cat << 'CONF' > /etc/mysql/mariadb.conf.d/50-server.cnf
[mysqld]
user = mysql
pid-file = /run/mysqld/mysqld.pid
socket = /run/mysqld/mysqld.sock
bind-address = 0.0.0.0
server-id = 2
CONF

service mariadb restart || service mysql restart

mysql -u root << 'SQL'
CREATE DATABASE IF NOT EXISTS db_shibuya_k16;
USE db_shibuya_k16;
CREATE TABLE IF NOT EXISTS request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_ip VARCHAR(50),
    worker_hostname VARCHAR(50),
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

STOP SLAVE;
RESET SLAVE ALL;
CHANGE MASTER TO
    MASTER_HOST='192.219.4.9',
    MASTER_USER='replica',
    MASTER_PASSWORD='replica123',
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=491;
START SLAVE;
SQL

echo "DB Slave inumaki terhubung ke Master."
EOF
chmod +x /root/soal13_inumaki.sh
bash /root/soal13_inumaki.sh

