#!/bin/bash
sed -i '/subnet 192.219.3.0 netmask 255.255.255.0 {/a \    host kugisaki {\n        hardware ethernet 02:42:1f:00:40:00;\n        fixed-address 192.219.3.99;\n    }' /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart

