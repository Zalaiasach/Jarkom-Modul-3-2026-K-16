cat << 'EOF' > /root/soal13_yaga.sh
#!/bin/bash
apt-get update && apt-get install -y mariadb-server mariadb-client

mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

cat << 'CONF' > /etc/mysql/mariadb.conf.d/50-server.cnf
[mysqld]
user = mysql
pid-file = /run/mysqld/mysqld.pid
socket = /run/mysqld/mysqld.sock
bind-address = 0.0.0.0
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = db_shibuya_k16
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

CREATE USER IF NOT EXISTS 'replica'@'%' IDENTIFIED BY 'replica123';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';

CREATE USER IF NOT EXISTS 'shibuya_user'@'192.219.4.%' IDENTIFIED BY 'shibuya123';
GRANT ALL PRIVILEGES ON db_shibuya_k16.* TO 'shibuya_user'@'192.219.4.%';
FLUSH PRIVILEGES;
SQL

echo "DB Master yaga siap."
EOF
chmod +x /root/soal13_yaga.sh
bash /root/soal13_yaga.sh

