cat << 'EOF' > /root/soal12_utahime.sh
#!/bin/bash
cat << 'CONF' > /etc/bind/named.conf.local
zone "jujutsu.k16.com" {
    type master;
    file "/etc/bind/zones/db.jujutsu.k16.com";
    allow-transfer { 192.219.1.3; };
    also-notify { 192.219.1.3; };
};

zone "1.219.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.1.219.192";
    allow-transfer { 192.219.1.3; };
    also-notify { 192.219.1.3; };
};
CONF

cat << 'CONF' > /etc/bind/zones/db.jujutsu.k16.com
$TTL 604800
@       IN      SOA     utahime.jujutsu.k16.com. admin.jujutsu.k16.com. (
                              2026101301 604800 86400 2419200 604800 )
@       IN      NS      utahime.jujutsu.k16.com.
@       IN      NS      shoko.jujutsu.k16.com.
utahime IN      A       192.219.1.2
shoko   IN      A       192.219.1.3

@       IN      A       192.219.1.4
gojo    IN      A       192.219.1.4
www     IN      CNAME   jujutsu.k16.com.
CONF

cat << 'CONF' > /etc/bind/zones/db.1.219.192
$TTL 604800
@       IN      SOA     utahime.jujutsu.k16.com. admin.jujutsu.k16.com. (
                              2026101301 604800 86400 2419200 604800 )
@       IN      NS      utahime.jujutsu.k16.com.
@       IN      NS      shoko.jujutsu.k16.com.
4       IN      PTR     jujutsu.k16.com.
CONF

cat << 'CONF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    dnssec-validation no;
    auth-nxdomain no;
    listen-on-v6 { any; };
};
CONF

/etc/init.d/named restart || /usr/sbin/named -u bind
echo "DNS Zone & Forwarder utahime selesai."
EOF
chmod +x /root/soal12_utahime.sh
bash /root/soal12_utahime.sh

