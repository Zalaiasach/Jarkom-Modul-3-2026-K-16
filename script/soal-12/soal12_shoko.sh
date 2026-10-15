cat << 'EOF' > /root/soal12_shoko.sh
#!/bin/bash
cat << 'CONF' > /etc/bind/named.conf.local
zone "jujutsu.k16.com" {
    type slave;
    file "/var/cache/bind/db.jujutsu.k16.com";
    masters { 192.219.1.2; };
};

zone "1.219.192.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.1.219.192";
    masters { 192.219.1.2; };
};
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
echo "Reverse zone & Forwarder shoko selesai."
EOF
chmod +x /root/soal12_shoko.sh
bash /root/soal12_shoko.sh

