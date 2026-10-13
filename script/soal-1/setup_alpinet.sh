cat << 'EOF' > /root/renew_ip.sh
#!/bin/sh
udhcpc -i eth0 -n -q
EOF
chmod +x /root/renew_ip.sh