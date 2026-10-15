cat << 'EOF' > /root/soal11_utahime.sh
#!/bin/bash
apt-get update && apt-get install -y bind9 dnsutils

mkdir -p /etc/bind/zones

cat << 'CONF' > /etc/bind/named.conf.local
zone "jujutsu.k16.com" {
    type master;
    file "/etc/bind/zones/db.jujutsu.k16.com";
    allow-transfer { 192.219.1.3; };
    also-notify { 192.219.1.3; };
};
CONF

cat << 'CONF' > /etc/bind/zones/db.jujutsu.k16.com
$TTL 604800
@       IN      SOA     utahime.jujutsu.k16.com. admin.jujutsu.k16.com. (
                              2026101301 ; Serial
                              604800     ; Refresh
                              86400      ; Retry
                              2419200    ; Expire
                              604800 )   ; Negative Cache TTL
;
@       IN      NS      utahime.jujutsu.k16.com.
@       IN      NS      shoko.jujutsu.k16.com.

utahime IN      A       192.219.1.2
shoko   IN      A       192.219.1.3
CONF

/etc/init.d/named restart || /usr/sbin/named -u bind
echo "DNS Master utahime siap."
EOF
chmod +x /root/soal11_utahime.sh
bash /root/soal11_utahime.sh

