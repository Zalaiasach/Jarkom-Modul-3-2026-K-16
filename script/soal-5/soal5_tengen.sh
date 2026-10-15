#!/bin/bash
cat << 'CONF' >> /etc/dhcp/dhcpd.conf

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

subnet 192.219.3.0 netmask 255.255.255.0 {
    option routers 192.219.3.1;
    option subnet-mask 255.255.255.0;
    option domain-name "k16.com";
    option domain-search "k16.com";
    option domain-name-servers 192.219.1.2, 192.219.1.3;

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

