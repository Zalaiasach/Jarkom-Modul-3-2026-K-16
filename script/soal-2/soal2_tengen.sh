cat << 'EOF' > /root/soal2_tengen.sh
#!/bin/bash
# 1. Pastikan nameserver mengarah ke NAT agar bisa mengunduh paket
echo "nameserver 192.168.122.1" > /etc/resolv.conf
# 2. Update repositori dan instal isc-dhcp-server
apt-get update
apt-get install -y isc-dhcp-server
# 3. Tentukan interface default DHCP Server
cat << 'DEF' > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
DEF
# 4. Konfigurasi dhcpd.conf
cat << 'CONF' > /etc/dhcp/dhcpd.conf
# Pengaturan global default
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
authoritative;
# Deklarasi Subnet Network 4 (Lokal subnet tanpa pool dinamis)
# Mencegah error "No subnet declaration for eth0"
subnet 192.219.4.0 netmask 255.255.255.0 {
}
# Scope DHCP untuk Network 2 (Client Divisi A)
subnet 192.219.2.0 netmask 255.255.255.0 {
    option routers 192.219.2.1;
    option subnet-mask 255.255.255.0;
    option domain-name-servers 192.168.122.1;
}
# Scope DHCP untuk Network 3 (Client Divisi B)
subnet 192.219.3.0 netmask 255.255.255.0 {
    option routers 192.219.3.1;
    option subnet-mask 255.255.255.0;
    option domain-name-servers 192.168.122.1;
}
CONF
# 5. Restart dan cek status service
service isc-dhcp-server restart
service isc-dhcp-server status
echo "Konfigurasi Soal 2 di tengen selesai."
EOF
chmod +x /root/soal2_tengen.sh
bash /root/soal2_tengen.sh