cat << 'EOF' > /root/setup_maki.sh
#!/bin/bash
ip addr flush dev eth0
ip addr add 192.219.4.4/24 dev eth0
ip link set eth0 up
ip route replace default via 192.219.4.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF
chmod +x /root/setup_maki.sh && bash /root/setup_maki.sh