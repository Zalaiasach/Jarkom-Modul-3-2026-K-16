#!/bin/bash
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

subnet 192.219.4.0 netmask 255.255.255.0 {
}

subnet 192.219.2.0 netmask 255.255.255.0 {
    option routers 192.219.2.1;
    option subnet-mask 255.255.255.0;

    pool {
        allow members of "pool1-clients";
        range 192.219.2.10 192.219.2.35;
    }

    pool {
        allow members of "pool2-clients";
        range 192.219.2.70 192.219.2.95;
    }
}
CONF
service isc-dhcp-server restart

