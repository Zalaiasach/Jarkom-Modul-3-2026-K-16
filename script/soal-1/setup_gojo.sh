cat << 'EOF' > /root/setup_gojo.sh
#!/bin/bash
ip addr flush dev eth0
ip addr add 192.219.1.4/24 dev eth0
ip link set eth0 up
ip route replace default via 192.219.1.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "gojo configured."
EOF
chmod +x /root/setup_gojo.sh && bash /root/setup_gojo.sh