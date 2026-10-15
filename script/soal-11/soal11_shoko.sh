cat << 'EOF' > /root/soal11_shoko.sh
#!/bin/bash
apt-get update && apt-get install -y bind9 dnsutils

cat << 'CONF' > /etc/bind/named.conf.local
zone "jujutsu.k16.com" {
    type slave;
    file "/var/cache/bind/db.jujutsu.k16.com";
    masters { 192.219.1.2; };
};
CONF

/etc/init.d/named restart || /usr/sbin/named -u bind
echo "DNS Slave shoko siap."
EOF
chmod +x /root/soal11_shoko.sh
bash /root/soal11_shoko.sh

