#!/bin/bash
sed -i '/subnet 192.219.2.0 netmask 255.255.255.0 {/a \    option broadcast-address 192.219.2.255;\n    option domain-name "k16.com";\n    option domain-search "k16.com";\n    option domain-name-servers 192.219.1.2, 192.219.1.3;' /etc/dhcp/dhcpd.conf
sed -i '/subnet 192.219.3.0 netmask 255.255.255.0 {/a \    option broadcast-address 192.219.3.255;' /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart

