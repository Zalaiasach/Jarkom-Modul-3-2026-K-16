#!/bin/bash
# 1. Konfigurasi IP Interface Internal
ip addr flush dev eth1
ip addr add 192.219.1.1/24 dev eth1
ip link set eth1 up

ip addr flush dev eth2
ip addr add 192.219.2.1/24 dev eth2
ip link set eth2 up

ip addr flush dev eth3
ip addr add 192.219.3.1/24 dev eth3
ip link set eth3 up

ip addr flush dev eth4
ip addr add 192.219.4.1/24 dev eth4
ip link set eth4 up

# 2. Aktifkan IP Forwarding & NAT Masquerade
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# 3. Jalankan DHCP Relay menuju tengen (192.219.4.10)
pkill -9 dhcrelay 2>/dev/null
dhcrelay -i eth2 -i eth3 -i eth4 192.219.4.10

echo "Autostart jichi berhasil."

