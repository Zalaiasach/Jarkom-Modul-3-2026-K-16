cat << 'EOF' > /root/setup_router.sh
#!/bin/bash
# Setup DNS untuk akses keluar
echo "nameserver 192.168.122.1" > /etc/resolv.conf
# Pasang IP statis langsung ke setiap interface
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
# Pastikan eth0 aktif dan meminta IP dari NAT (DHCP)
ip link set eth0 up
udhcpc -i eth0 -n -q 2>/dev/null || dhclient eth0 2>/dev/null
# Aktifkan forwarding & NAT Masquerade
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "Router jichi berhasil aktif!"
EOF
chmod +x /root/setup_router.sh
bash /root/setup_router.sh