cat << 'EOF' > /root/setup_tengen.sh
#!/bin/bash
# Pastikan IP dan route terpasang
ip addr flush dev eth0
ip addr add 192.219.4.10/24 dev eth0
ip link set eth0 up
ip route replace default via 192.219.4.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
# Start service isc-dhcp-server
service isc-dhcp-server restart
EOF
chmod +x /root/setup_tengen.sh