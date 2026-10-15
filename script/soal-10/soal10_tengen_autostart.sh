#!/bin/bash
# 1. Konfigurasi IP & Gateway tengen
ip addr flush dev eth0
ip addr add 192.219.4.10/24 dev eth0
ip link set eth0 up
ip route replace default via 192.219.4.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 2. Interface default isc-dhcp-server
cat << 'DEF' > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
DEF

# 3. Konfigurasi Master DHCP Server (Soal 4, 5, 6, 7)
cat << 'CONF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
authoritative;

class "pool1-clients" {
    match if (
        substring(option host-name, 0, 7) = "itadori" or
        substring(option host-name, 0, 9) = "fushiguro"
    );
}

class "pool2-clients" {
    match if (
        substring(option host-name, 0, 5) = "zenin" or
        substring(option host-name, 0, 7) = "okkotsu"
    );
}

class "short-lease-clients" {
    match if (
        substring(option host-name, 0, 3) = "ino" or
        substring(option host-name, 0, 8) = "kusakabe"
    );
}

class "long-lease-clients" {
    match if (
        substring(option host-name, 0, 4) = "miwa"
    );
}

subnet 192.219.4.0 netmask 255.255.255.0 {
}

subnet 192.219.2.0 netmask 255.255.255.0 {
    option routers 192.219.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.219.2.255;
    option domain-name "k16.com";
    option domain-search "k16.com";
    option domain-name-servers 192.219.1.2, 192.219.1.3;

    pool {
        allow members of "pool1-clients";
        range 192.219.2.10 192.219.2.35;
    }

    pool {
        allow members of "pool2-clients";
        range 192.219.2.70 192.219.2.95;
    }
}

subnet 192.219.3.0 netmask 255.255.255.0 {
    option routers 192.219.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.219.3.255;
    option domain-name "k16.com";
    option domain-search "k16.com";
    option domain-name-servers 192.219.1.2, 192.219.1.3;

    host kugisaki {
        hardware ethernet 02:42:1f:00:40:00;
        fixed-address 192.219.3.99;
    }

    pool {
        allow members of "short-lease-clients";
        range 192.219.3.10 192.219.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    pool {
        allow members of "long-lease-clients";
        range 192.219.3.100 192.219.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }
}
CONF

service isc-dhcp-server restart
echo "Autostart tengen selesai."

