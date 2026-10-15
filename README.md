# Laporan Resmi Praktikum Jaringan Komputer
## Modul 3: Insiden Shibuya — Kelompok K-16

---

### Identitas Kelompok
* **Kelompok:** K-16
* **Domain Utama:** `jujutsu.k16.com` / `www.jujutsu.k16.com`
* **Database:** `db_shibuya_k16`

---

## 📌 Daftar Alamat IP & Pembagian Jaringan

| Node | Interface / Peran | Alamat IP | Subnet / Gateway |
| :--- | :--- | :--- | :--- |
| **`jichi`** | Router (eth0 / NAT) | `192.168.122.245/24` | Default via `192.168.122.1` |
| **`jichi`** | Router (eth1 / DMZ) | `192.219.1.1/24` | Subnet Network 1 |
| **`jichi`** | Router (eth2 / Divisi A) | `192.219.2.1/24` | Subnet Network 2 |
| **`jichi`** | Router (eth3 / Divisi B) | `192.219.3.1/24` | Subnet Network 3 |
| **`jichi`** | Router (eth4 / Data Center) | `192.219.4.1/24` | Subnet Network 4 |
| **`utahime`** | DNS Master | `192.219.1.2/24` | Gateway `192.219.1.1` |
| **`shoko`** | DNS Slave | `192.219.1.3/24` | Gateway `192.219.1.1` |
| **`gojo`** | Public Gateway / Reverse Proxy | `192.219.1.4/24` | Gateway `192.219.1.1` |
| **`tengen`** | DHCP Server | `192.219.4.10/24` | Gateway `192.219.4.1` |
| **`yaga`** | Database Master (MariaDB) | `192.219.4.9/24` | Gateway `192.219.4.1` |
| **`inumaki`** | Database Slave (MariaDB) | `192.219.4.10/24` | Gateway `192.219.4.1` |
| **`geto`** | Internal Load Balancer API | `192.219.4.3/24` | Gateway `192.219.4.1` |
| **`maki`** | Frontend Web Worker 1 | `192.219.4.4/24` | Gateway `192.219.4.1` |
| **`panda`** | Frontend Web Worker 2 | `192.219.4.5/24` | Gateway `192.219.4.1` |
| **`nanami`** | API Worker 1 | `192.219.4.6/24` | Gateway `192.219.4.1` |
| **`todo`** | API Worker 2 | `192.219.4.7/24` | Gateway `192.219.4.1` |
| **`kirara`** | API Backup Worker | `192.219.4.8/24` | Gateway `192.219.4.1` |
| **`kusakabe`** | Klien Divisi B (Tester / AB) | `192.219.3.2/24` | Gateway `192.219.3.1` |
| **`kugisaki`** | Klien VIP Personel | `192.219.3.99/24` | Static Lease DHCP |

---

## 🗺️ Topologi Jaringan (GNS3)

Berikut adalah topologi arsitektur jaringan virtual yang dikonfigurasi pada simulator GNS3:

![Topologi GNS3 Kelompok K-16](images/topologi_gns3.png)

---

# BAGIAN I: SOAL 1 – 10 (DHCP Server, DHCP Relay, & Addressing)

### SOAL 1: Base Addressing & Routing Router (`jichi`)
Mengatur IP interface internal (`eth1` s.d. `eth4`), mengaktifkan IP forwarding, dan menyetel NAT Masquerade ke arah luar (`eth0`).

* **Node:** `jichi`
* **Nama File:** `/root/soal1_jichi.sh`
* **Isi Skrip:**
```bash
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

echo "Konfigurasi Base Network & NAT jichi berhasil."
```
* **Penanganan Reset:**
```bash
grep -qxF 'bash /root/soal1_jichi.sh' /root/.bashrc || echo 'bash /root/soal1_jichi.sh' >> /root/.bashrc
```

* **Tangkapan Layar Bukti Pengujian:**
![Bukti Pengujian Soal 1](images/soal1_jichi_routing.png)

---

### SOAL 2: Base Addressing Server Data Center (`tengen`)
Mengatur IP statis `192.219.4.10/24`, gateway default ke router `jichi`, dan nameserver DNS.

* **Node:** `tengen`
* **Nama File:** `/root/soal2_tengen.sh`
* **Isi Skrip:**
```bash
#!/bin/bash
ip addr flush dev eth0
ip addr add 192.219.4.10/24 dev eth0
ip link set eth0 up
ip route replace default via 192.219.4.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf

echo "Konfigurasi IP Statis tengen berhasil."
```
* **Penanganan Reset:**
```bash
grep -qxF 'bash /root/soal2_tengen.sh' /root/.bashrc || echo 'bash /root/soal2_tengen.sh' >> /root/.bashrc
```

* **Tangkapan Layar Bukti Pengujian:**
![Bukti Pengujian Soal 2](images/soal2_tengen_ip.png)

---

### SOAL 3: DHCP Relay pada Router (`jichi`)
Menjalankan service `dhcrelay` untuk meneruskan permintaan DHCP dari `eth2` (Net 2) dan `eth3` (Net 3) ke server `tengen` (`192.219.4.10` via `eth4`).

* **Node:** `jichi`
* **Nama File:** `/root/soal3_jichi.sh`
* **Isi Skrip:**
```bash
#!/bin/bash
pkill -9 dhcrelay 2>/dev/null
dhcrelay -i eth2 -i eth3 -i eth4 192.219.4.10

echo "DHCP Relay aktif menuju 192.219.4.10."
```
* **Penanganan Reset:**
```bash
grep -qxF 'bash /root/soal3_jichi.sh' /root/.bashrc || echo 'bash /root/soal3_jichi.sh' >> /root/.bashrc
```

* **Tangkapan Layar Bukti Pengujian:**
![Bukti Pengujian Soal 3](images/soal3_jichi_relay.png)

---

### SOAL 4: Pembagian Pool Dinamis Divisi A (Network 2)
Membagi Network 2 menjadi Pool 1 (`192.219.2.10`–`192.219.2.35` untuk itadori & fushiguro) dan Pool 2 (`192.219.2.70`–`192.219.2.95` untuk zenin & okkotsu).

* **Node:** `tengen` (Server)
* **Nama File:** `/root/soal4_tengen.sh`
* **Isi Skrip:**
```bash
#!/bin/bash
cat << 'CONF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
authoritative;

class "pool1-clients" {
    match if (
        substring(option host-name, 0, 7) = "itadori" or
        substring(option host-name, 0, 9) = "fushiguro"
    );
}

class "pool2-clients" {
    match if (
        substring(option host-name, 0, 5) = "zenin" or
        substring(option host-name, 0, 7) = "okkotsu"
    );
}

subnet 192.219.4.0 netmask 255.255.255.0 {
}

subnet 192.219.2.0 netmask 255.255.255.0 {
    option routers 192.219.2.1;
    option subnet-mask 255.255.255.0;

    pool {
        allow members of "pool1-clients";
        range 192.219.2.10 192.219.2.35;
    }

    pool {
        allow members of "pool2-clients";
        range 192.219.2.70 192.219.2.95;
    }
}
CONF
service isc-dhcp-server restart
```

* **Tangkapan Layar Bukti Pengujian:**
![Bukti Pengujian Soal 4](images/soal4_divisi_a_pool.png)

---

### SOAL 5: Pengaturan Lease Time & DNS Divisi B (Network 3)
Short lease 1800s (`.3.10`–`.3.89` untuk ino & kusakabe), Long lease 43200s (`.3.100`–`.3.199` untuk miwa), DNS `192.219.1.2`, `192.219.1.3`, domain `k16.com`.

* **Node:** `tengen` (Server)
* **Nama File:** `/root/soal5_tengen.sh`
* **Isi Skrip:**
```bash
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
```

* **Tangkapan Layar Bukti Pengujian:**
![Bukti Pengujian Soal 5](images/soal5_divisi_b_lease.png)

---

### SOAL 6: Static Lease VIP Personel (`kugisaki`)
Menetapkan fixed IP `192.219.3.99` untuk MAC Address `02:42:1f:00:40:00`.

* **Node:** `tengen` (Server)
* **Nama File:** `/root/soal6_tengen.sh`
* **Isi Skrip:**
```bash
#!/bin/bash
sed -i '/subnet 192.219.3.0 netmask 255.255.255.0 {/a \    host kugisaki {\n        hardware ethernet 02:42:1f:00:40:00;\n        fixed-address 192.219.3.99;\n    }' /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
```

* **Tangkapan Layar Bukti Pengujian:**
![Bukti Pengujian Soal 6](images/soal6_kugisaki_static.png)

---

### SOAL 7: Verifikasi Parameter Jaringan Lengkap
Menyeragamkan DNS ganda, domain search `k16.com`, dan broadcast address `x.x.x.255` untuk semua subnet.

* **Node:** `tengen` (Server)
* **Nama File:** `/root/soal7_tengen.sh`
* **Isi Skrip:**
```bash
#!/bin/bash
sed -i '/subnet 192.219.2.0 netmask 255.255.255.0 {/a \    option broadcast-address 192.219.2.255;\n    option domain-name "k16.com";\n    option domain-search "k16.com";\n    option domain-name-servers 192.219.1.2, 192.219.1.3;' /etc/dhcp/dhcpd.conf
sed -i '/subnet 192.219.3.0 netmask 255.255.255.0 {/a \    option broadcast-address 192.219.3.255;' /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
```

* **Tangkapan Layar Bukti Pengujian:**
![Bukti Pengujian Soal 7](images/soal7_network_parameters.png)

---

### SOAL 8: Packet Capture Analisis DORA Handshake
Menangkap 4 paket DORA (Discover, Offer, Request, ACK) dan membaca field `giaddr`.

* **Node:** `tengen` (Server)
* **Nama File:** `/root/soal8_capture.sh`
```bash
#!/bin/bash
tcpdump -i eth0 -vvv -en -s 0 'port 67 or port 68'
```

* **Tangkapan Layar Bukti Analisis Paket DORA:**
![Bukti Pengujian Soal 8](images/soal8_dora_capture.png)

---

### SOAL 9: Uji Gangguan Relay & Pemulihan (Failover Test)
Menghentikan dan menyalakan kembali service `dhcrelay` pada `jichi` untuk menguji toleransi kegagalan alokasi IP DHCP klien.

* **Node:** `jichi` (Router)
* **Nama File Stop:** `/root/soal9_stop_relay.sh`
```bash
#!/bin/bash
pkill -9 dhcrelay 2>/dev/null
echo "Relay dihentikan."
```
* **Nama File Start:** `/root/soal9_start_relay.sh`
```bash
#!/bin/bash
pkill -9 dhcrelay 2>/dev/null
dhcrelay -i eth2 -i eth3 -i eth4 192.219.4.10
echo "Relay dipulihkan."
```

* **Tangkapan Layar Bukti Uji Gangguan & Pemulihan:**
![Bukti Pengujian Soal 9](images/soal9_relay_failover.png)

---

### SOAL 10: Autostart Penuh Seluruh Layanan (Soal 1–10)
Menyatukan seluruh logika konfigurasi DHCP & routing ke dalam satu file autostart master pada `tengen` dan `jichi`.

* **Node:** `tengen`
* **Nama File:** `/root/soal10_tengen_autostart.sh`
* **Penanganan Reset:**
```bash
grep -qxF 'bash /root/soal10_tengen_autostart.sh' /root/.bashrc || echo 'bash /root/soal10_tengen_autostart.sh' >> /root/.bashrc
```

* **Node:** `jichi`
* **Nama File:** `/root/soal10_jichi_autostart.sh`
* **Penanganan Reset:**
```bash
grep -qxF 'bash /root/soal10_jichi_autostart.sh' /root/.bashrc || echo 'bash /root/soal10_jichi_autostart.sh' >> /root/.bashrc
```

* **Tangkapan Layar Bukti Autostart (.bashrc):**
![Bukti Pengujian Soal 10](images/soal10_autostart_verification.png)

---

# BAGIAN II: SOAL 11 – 20 (DNS, Database Replikasi, Nginx Cluster, Caching, & Benchmark)

### SOAL 11: DNS Master & DNS Slave (BIND9)
Membangun sistem penamaan domain resmi `jujutsu.k16.com` menggunakan BIND9 dengan `utahime` sebagai Master dan `shoko` sebagai Slave, mengatur SOA record, NS delegasi, dan `allow-transfer` otomatis.

#### Node: utahime (DNS Master - 192.219.1.2)
* **Nama File:** `/root/soal11_utahime.sh`
* **Isi Skrip:**
```bash
cat << 'EOF' > /root/soal11_utahime.sh
#!/bin/bash
apt-get update && apt-get install -y bind9 dnsutils

mkdir -p /etc/bind/zones

cat << 'CONF' > /etc/bind/named.conf.local
zone "jujutsu.k16.com" {
    type master;
    file "/etc/bind/zones/db.jujutsu.k16.com";
    allow-transfer { 192.219.1.3; };
    also-notify { 192.219.1.3; };
};
CONF

cat << 'CONF' > /etc/bind/zones/db.jujutsu.k16.com
$TTL 604800
@       IN      SOA     utahime.jujutsu.k16.com. admin.jujutsu.k16.com. (
                              2026101301 ; Serial
                              604800     ; Refresh
                              86400      ; Retry
                              2419200    ; Expire
                              604800 )   ; Negative Cache TTL
;
@       IN      NS      utahime.jujutsu.k16.com.
@       IN      NS      shoko.jujutsu.k16.com.

utahime IN      A       192.219.1.2
shoko   IN      A       192.219.1.3
CONF

/etc/init.d/named restart || /usr/sbin/named -u bind
echo "DNS Master utahime siap."
EOF
chmod +x /root/soal11_utahime.sh
bash /root/soal11_utahime.sh
```
* **Penanganan Reset:**
```bash
grep -qxF 'bash /root/soal11_utahime.sh' /root/.bashrc || echo 'bash /root/soal11_utahime.sh' >> /root/.bashrc
```

#### Node: shoko (DNS Slave - 192.219.1.3)
* **Nama File:** `/root/soal11_shoko.sh`
* **Isi Skrip:**
```bash
cat << 'EOF' > /root/soal11_shoko.sh
#!/bin/bash
apt-get update && apt-get install -y bind9 dnsutils

cat << 'CONF' > /etc/bind/named.conf.local
zone "jujutsu.k16.com" {
    type slave;
    file "/var/cache/bind/db.jujutsu.k16.com";
    masters { 192.219.1.2; };
};
CONF

/etc/init.d/named restart || /usr/sbin/named -u bind
echo "DNS Slave shoko siap."
EOF
chmod +x /root/soal11_shoko.sh
bash /root/soal11_shoko.sh
```
* **Penanganan Reset:**
```bash
grep -qxF 'bash /root/soal11_shoko.sh' /root/.bashrc || echo 'bash /root/soal11_shoko.sh' >> /root/.bashrc
```

#### Verifikasi Soal 11:
```bash
# Query ke Master
dig @192.219.1.2 jujutsu.k16.com
# Query ke Slave
dig @192.219.1.3 jujutsu.k16.com
```

* **Tangkapan Layar Bukti Pengujian DNS Master & Slave:**
![Bukti Pengujian Soal 11](images/soal11_bind9_master_slave.png)
<img width="1024" height="665" alt="image" src="https://github.com/user-attachments/assets/ec799c44-6c82-4c75-a0c4-0bc3ba788da0" />

---

### SOAL 12: A Record, CNAME, Reverse DNS (PTR), & DNS Forwarder
Memetakan `jujutsu.k16.com` ke IP `gojo` (`192.219.1.4`), alias CNAME `www`, Reverse DNS zona PTR `1.219.192.in-addr.arpa`, dan Forwarder ke `192.168.122.1`.

#### Node: utahime (DNS Master)
* **Nama File:** `/root/soal12_utahime.sh`
* **Isi Skrip:**
```bash
cat << 'EOF' > /root/soal12_utahime.sh
#!/bin/bash
cat << 'CONF' > /etc/bind/named.conf.local
zone "jujutsu.k16.com" {
    type master;
    file "/etc/bind/zones/db.jujutsu.k16.com";
    allow-transfer { 192.219.1.3; };
    also-notify { 192.219.1.3; };
};

zone "1.219.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.1.219.192";
    allow-transfer { 192.219.1.3; };
    also-notify { 192.219.1.3; };
};
CONF

cat << 'CONF' > /etc/bind/zones/db.jujutsu.k16.com
$TTL 604800
@       IN      SOA     utahime.jujutsu.k16.com. admin.jujutsu.k16.com. (
                              2026101301 604800 86400 2419200 604800 )
@       IN      NS      utahime.jujutsu.k16.com.
@       IN      NS      shoko.jujutsu.k16.com.
utahime IN      A       192.219.1.2
shoko   IN      A       192.219.1.3

@       IN      A       192.219.1.4
gojo    IN      A       192.219.1.4
www     IN      CNAME   jujutsu.k16.com.
CONF

cat << 'CONF' > /etc/bind/zones/db.1.219.192
$TTL 604800
@       IN      SOA     utahime.jujutsu.k16.com. admin.jujutsu.k16.com. (
                              2026101301 604800 86400 2419200 604800 )
@       IN      NS      utahime.jujutsu.k16.com.
@       IN      NS      shoko.jujutsu.k16.com.
4       IN      PTR     jujutsu.k16.com.
CONF

cat << 'CONF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    dnssec-validation no;
    auth-nxdomain no;
    listen-on-v6 { any; };
};
CONF

/etc/init.d/named restart || /usr/sbin/named -u bind
echo "DNS Zone & Forwarder utahime selesai."
EOF
chmod +x /root/soal12_utahime.sh
bash /root/soal12_utahime.sh
```

#### Node: shoko (DNS Slave)
* **Nama File:** `/root/soal12_shoko.sh`
* **Isi Skrip:**
```bash
cat << 'EOF' > /root/soal12_shoko.sh
#!/bin/bash
cat << 'CONF' > /etc/bind/named.conf.local
zone "jujutsu.k16.com" {
    type slave;
    file "/var/cache/bind/db.jujutsu.k16.com";
    masters { 192.219.1.2; };
};

zone "1.219.192.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.1.219.192";
    masters { 192.219.1.2; };
};
CONF

cat << 'CONF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    dnssec-validation no;
    auth-nxdomain no;
    listen-on-v6 { any; };
};
CONF

/etc/init.d/named restart || /usr/sbin/named -u bind
echo "Reverse zone & Forwarder shoko selesai."
EOF
chmod +x /root/soal12_shoko.sh
bash /root/soal12_shoko.sh
```

#### Verifikasi Soal 12 dari Klien (`kusakabe`):
```bash
# 1. Cek CNAME
dig CNAME www.jujutsu.k16.com +short
# Output: jujutsu.k16.com.

# 2. Cek Reverse PTR
dig -x 192.219.1.4 +short
# Output: jujutsu.k16.com.

# 3. Cek Forwarder Internet
ping -c 3 google.com
# Output: 3 packets transmitted, 3 packets received, 0% packet loss
```

* **Tangkapan Layar Bukti Pengujian CNAME, PTR, & Forwarder:**
![Bukti Pengujian Soal 12](images/soal12_cname_ptr_forwarder.png)
<img width="1024" height="665" alt="image" src="https://github.com/user-attachments/assets/26f9a61c-c47b-4b7e-9f0f-4ce919c6de4b" />

---

### SOAL 13: Replikasi MariaDB Master-Slave (`yaga` & `inumaki`)
Konfigurasi database MariaDB terpusat redundan: `yaga` sebagai DB-Master dan `inumaki` sebagai DB-Slave untuk menyalin `db_shibuya_k16.request_logs` secara real-time.

#### Node: yaga (DB Master - 192.219.4.9)
* **Nama File:** `/root/soal13_yaga.sh`
* **Isi Skrip:**
```bash
cat << 'EOF' > /root/soal13_yaga.sh
#!/bin/bash
apt-get update && apt-get install -y mariadb-server mariadb-client

mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

cat << 'CONF' > /etc/mysql/mariadb.conf.d/50-server.cnf
[mysqld]
user = mysql
pid-file = /run/mysqld/mysqld.pid
socket = /run/mysqld/mysqld.sock
bind-address = 0.0.0.0
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = db_shibuya_k16
CONF

service mariadb restart || service mysql restart

mysql -u root << 'SQL'
CREATE DATABASE IF NOT EXISTS db_shibuya_k16;
USE db_shibuya_k16;

CREATE TABLE IF NOT EXISTS request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_ip VARCHAR(50),
    worker_hostname VARCHAR(50),
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE USER IF NOT EXISTS 'replica'@'%' IDENTIFIED BY 'replica123';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';

CREATE USER IF NOT EXISTS 'shibuya_user'@'192.219.4.%' IDENTIFIED BY 'shibuya123';
GRANT ALL PRIVILEGES ON db_shibuya_k16.* TO 'shibuya_user'@'192.219.4.%';
FLUSH PRIVILEGES;
SQL

echo "DB Master yaga siap."
EOF
chmod +x /root/soal13_yaga.sh
bash /root/soal13_yaga.sh
```

#### Node: inumaki (DB Slave - 192.219.4.10)
* **Nama File:** `/root/soal13_inumaki.sh`
* **Isi Skrip:**
```bash
cat << 'EOF' > /root/soal13_inumaki.sh
#!/bin/bash
apt-get update && apt-get install -y mariadb-server mariadb-client

cat << 'CONF' > /etc/mysql/mariadb.conf.d/50-server.cnf
[mysqld]
user = mysql
pid-file = /run/mysqld/mysqld.pid
socket = /run/mysqld/mysqld.sock
bind-address = 0.0.0.0
server-id = 2
CONF

service mariadb restart || service mysql restart

mysql -u root << 'SQL'
CREATE DATABASE IF NOT EXISTS db_shibuya_k16;
USE db_shibuya_k16;
CREATE TABLE IF NOT EXISTS request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_ip VARCHAR(50),
    worker_hostname VARCHAR(50),
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

STOP SLAVE;
RESET SLAVE ALL;
CHANGE MASTER TO
    MASTER_HOST='192.219.4.9',
    MASTER_USER='replica',
    MASTER_PASSWORD='replica123',
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=491;
START SLAVE;
SQL

echo "DB Slave inumaki terhubung ke Master."
EOF
chmod +x /root/soal13_inumaki.sh
bash /root/soal13_inumaki.sh
```

#### Verifikasi Soal 13:
* **Insert di `yaga`:**
  ```bash
  mysql -u root -e "USE db_shibuya_k16; INSERT INTO request_logs (client_ip, worker_hostname) VALUES ('192.219.3.2', 'sukuna');"
  ```
* **Cek Replikasi di `inumaki`:**
  ```bash
  mysql -u root -e "SELECT * FROM db_shibuya_k16.request_logs;"
  # Hasil: Data 'sukuna' muncul seketika secara real-time.
  ```

* **Tangkapan Layar Bukti Replikasi Master-Slave:**
![Bukti Pengujian Soal 13](images/soal13_mariadb_replication.png)
<img width="1024" height="665" alt="image" src="https://github.com/user-attachments/assets/f6d8e910-bf56-4c0c-8911-f81303fb21a8" />

* **Tangkapan Layar Konfigurasi Terminal Live Master (Yaga):**
![Konfigurasi Master Yaga](images/soal13_yaga_master_real.png)
<img width="1024" height="665" alt="image" src="https://github.com/user-attachments/assets/75982d42-a983-41bf-a26b-a3ccbb576033" />

---

### SOAL 14: Worker Frontend & Worker API dengan Akses Terbatas
Web Frontend (`maki`, `panda`) menyajikan halaman berisi hostname masing-masing, akses dibatasi hanya dari proxy `gojo` (`192.219.1.4`). Worker API (`nanami`, `todo`, `kirara`) mencatat request ke DB `yaga`, akses dibatasi hanya dari `geto` (`192.219.4.3`).

#### Node: maki & panda (Frontend Workers - 192.219.4.4 & 192.219.4.5)
* **Nama File:** `/root/soal14_frontend.sh`
* **Isi Skrip:**
```bash
cat << 'EOF' > /root/soal14_frontend.sh
#!/bin/bash
apt-get update && apt-get install -y nginx php-fpm

service php8.4-fpm start

mkdir -p /var/www/html
cat << 'PHP' > /var/www/html/index.php
<?php
echo "Frontend Worker: " . gethostname() . "\n";
?>
PHP

cat << 'CONF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    server_name jujutsu.k16.com www.jujutsu.k16.com;
    root /var/www/html;
    index index.php index.html;

    allow 192.219.1.4;
    deny all;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
CONF

nginx -t && service nginx restart
EOF
chmod +x /root/soal14_frontend.sh
bash /root/soal14_frontend.sh
```

#### Node: nanami, todo, kirara (API Workers - 192.219.4.6, 192.219.4.7, 192.219.4.8)
* **Nama File:** `/root/soal14_api.sh`
* **Isi Skrip:**
```bash
cat << 'EOF' > /root/soal14_api.sh
#!/bin/bash
apt-get update && apt-get install -y nginx php-fpm php-mysql

service php8.4-fpm start

mkdir -p /var/www/api
cat << 'PHP' > /var/www/api/index.php
<?php
$client_ip = $_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'];
$hostname = gethostname();

$conn = new mysqli("192.219.4.9", "shibuya_user", "shibuya123", "db_shibuya_k16");
if (!$conn->connect_error) {
    $stmt = $conn->prepare("INSERT INTO request_logs (client_ip, worker_hostname) VALUES (?, ?)");
    $stmt->bind_param("ss", $client_ip, $hostname);
    $stmt->execute();
    $stmt->close();
    $conn->close();
}

header("Content-Type: application/json");
echo json_encode([
    "status" => "success",
    "worker" => $hostname,
    "client_ip" => $client_ip
]) . "\n";
?>
PHP

cat << 'CONF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    root /var/www/api;
    index index.php;

    allow 192.219.4.3;
    allow 127.0.0.1;
    deny all;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_param HTTP_X_REAL_IP $http_x_real_ip;
        fastcgi_param HTTP_X_FORWARDED_FOR $http_x_forwarded_for;
    }
}
CONF

nginx -t && service nginx restart
EOF
chmod +x /root/soal14_api.sh
bash /root/soal14_api.sh
```

#### Verifikasi Soal 14:
Akses langsung dari klien `kusakabe` ke worker backend akan ditolak (403 Forbidden):
```bash
curl -i http://192.219.4.4/ | grep "HTTP/1.1" # Output: 403 Forbidden
curl -i http://192.219.4.6/ | grep "HTTP/1.1" # Output: 403 Forbidden
```

* **Tangkapan Layar Bukti Restriksi Akses:**
![Bukti Pengujian Soal 14](images/soal14_worker_restriction.png)
<img width="1024" height="665" alt="image" src="https://github.com/user-attachments/assets/b00023ee-d4a9-4ea6-b187-b0b81690a96a" />

---

### SOAL 15: Internal Load Balancer API pada `geto` (Weighted Round Robin 3:1)
Mengatur Nginx pada `geto` mengarahkan beban request API ke `nanami` dan `todo` dengan bobot rasio 3:1.

#### Node: geto (Load Balancer - 192.219.4.3)
* **Nama File:** `/root/soal15_geto.sh`
* **Isi Skrip:**
```bash
cat << 'EOF' > /root/soal15_geto.sh
#!/bin/bash
apt-get update && apt-get install -y nginx curl

cat << 'CONF' > /etc/nginx/sites-available/default
upstream api_cluster {
    server 192.219.4.6:80 weight=3 max_fails=2 fail_timeout=5s; # nanami
    server 192.219.4.7:80 weight=1 max_fails=2 fail_timeout=5s; # todo
    server 192.219.4.8:80 backup;                               # kirara
}

server {
    listen 80 default_server;

    set_real_ip_from 192.219.1.4;
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 2s;
        proxy_read_timeout 3s;
    }
}
CONF

nginx -t && service nginx restart
EOF
chmod +x /root/soal15_geto.sh
bash /root/soal15_geto.sh
```

#### Verifikasi Soal 15 (Loop Request dari `geto`):
```bash
for i in $(seq 1 12); do curl -s http://127.0.0.1/ | grep -o '"worker":"[^"]*"'; done
```
* **Hasil Terminal:**
  ```text
  "worker":"nanami"
  "worker":"nanami"
  "worker":"nanami"
  "worker":"nanami"
  "worker":"nanami"
  "worker":"todo"
  "worker":"nanami"
  "worker":"nanami"
  "worker":"todo"
  "worker":"nanami"
  "worker":"nanami"
  "worker":"nanami"
  ```
  *(Nanami menerima tepat 3x lebih banyak respon daripada Todo).*

* **Tangkapan Layar Bukti Weighted Round Robin 3:1:**
![Bukti Pengujian Soal 15](images/soal15_load_balancer_wrr.png)
<img width="1024" height="665" alt="image" src="https://github.com/user-attachments/assets/c2529fba-f083-4054-b724-a9f414b9eef7" />

---

### SOAL 16 & 17: Public Gateway DMZ (`gojo`), Routing, & Real Client IP
Melayani `jujutsu.k16.com` dengan Path-Based Routing (`/` ke Frontend maki/panda, `/api` ke Geto), serta meneruskan alamat IP asli klien melalui `X-Real-IP` dan `X-Forwarded-For` hingga tercatat di tabel `request_logs`.

#### Node: gojo (Public Gateway - 192.219.1.4)
* **Nama File:** `/root/soal16_gojo.sh`
* **Isi Skrip:**
```bash
cat << 'EOF' > /root/soal16_gojo.sh
#!/bin/bash
apt-get update && apt-get install -y nginx curl

mkdir -p /var/cache/nginx

cat << 'CONF' > /etc/nginx/sites-available/default
upstream frontend_cluster {
    server 192.219.4.4:80;
    server 192.219.4.5:80;
}

proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=WEB_CACHE:10m max_size=100m inactive=60m use_temp_path=off;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

server {
    listen 80 default_server;
    server_name jujutsu.k16.com www.jujutsu.k16.com;

    location /api {
        limit_req zone=api_limit nodelay;
        limit_req_status 503;

        proxy_pass http://192.219.4.3/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        proxy_pass http://frontend_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_cache WEB_CACHE;
        proxy_cache_valid 200 302 10m;
        add_header X-Cache-Status $upstream_cache_status;
    }
}
CONF

nginx -t && service nginx restart
EOF
chmod +x /root/soal16_gojo.sh
bash /root/soal16_gojo.sh
```

#### Verifikasi Soal 16 & 17 dari Klien (`kusakabe`):
```bash
# 1. Akses web root
curl -s http://jujutsu.k16.com/
# Output: Frontend Worker: maki

# 2. Akses /api
curl -s http://jujutsu.k16.com/api
# Output: {"status":"success","worker":"nanami","client_ip":"192.219.3.2"}

# 3. Verifikasi Real Client IP di Database (node yaga):
mysql -u root -e "SELECT id, client_ip, worker_hostname FROM db_shibuya_k16.request_logs ORDER BY id DESC LIMIT 1;"
# Output: client_ip tercatat 192.219.3.2 (bukan IP gojo / geto)
```

* **Tangkapan Layar Bukti Path Routing & Real IP Logging:**
![Bukti Pengujian Soal 16 dan 17](images/soal16_17_real_ip_gateway.png)
<img width="1024" height="665" alt="image" src="https://github.com/user-attachments/assets/66959268-0ec2-4a9f-911a-ec199518cd46" />

---

### SOAL 18: Backup Worker API (`kirara`) & Passive Health Check
Menerapkan passive health check (`max_fails=2` dan `fail_timeout=5s`) di `geto` dan server cadangan `kirara`. Saat layanan Nginx di `nanami` dan `todo` dimatikan, request langsung dialihkan ke `kirara` tanpa error 502 Bad Gateway.

#### Pembuktian Failover:
1. Matikan Nginx di `nanami` dan `todo`:
   ```bash
   service nginx stop
   ```
2. Uji dari klien `kusakabe`:
   ```bash
   curl -s http://jujutsu.k16.com/api
   ```
   * **Hasil Terminal Klien:**
     ```json
     {"status":"success","worker":"kirara","client_ip":"192.219.3.2"}
     ```
     *(Respons valid dari Kirara tanpa error 502).*
3. Hidupkan kembali:
   ```bash
   service nginx start
   ```

* **Tangkapan Layar Bukti Failover Health Check (Kirara):**
![Bukti Pengujian Soal 18](images/soal18_failover_kirara.png)
<img width="1024" height="665" alt="image" src="https://github.com/user-attachments/assets/bee9c4c9-ef89-49c7-8bbc-89e5ad5c773d" />

---

### SOAL 19: Nginx Proxy Caching & Rate Limiting pada `gojo`
Halaman web frontend dicache selama 10 menit dengan header `X-Cache-Status` (`MISS`/`HIT`), dan path `/api` dibatasi 10 request per detik per client IP.

#### Verifikasi Soal 19 dari Klien (`kusakabe`):
* **Uji Caching Frontend:**
  ```bash
  # Request 1
  curl -i http://jujutsu.k16.com/ | grep "X-Cache-Status"
  # Output: X-Cache-Status: MISS

  # Request 2
  curl -i http://jujutsu.k16.com/ | grep "X-Cache-Status"
  # Output: X-Cache-Status: HIT
  ```

* **Uji Rate Limiting 10 r/s (Burst Request ke `/api`):**
  ```bash
  for i in $(seq 1 15); do curl -s -o /dev/null -w "%{http_code} " http://jujutsu.k16.com/api; done
  ```
  * **Hasil Terminal:**
    ```text
    200 503 503 503 503 503 503 503 503 503 503 503 200 503 503
    ```
    *(Kelebihan kuota langsung ditolak dengan kode status HTTP 503).*

* **Tangkapan Layar Bukti Caching & Rate Limiting:**
![Bukti Pengujian Soal 19](images/soal19_caching_ratelimit.png)
<img width="1024" height="665" alt="image" src="https://github.com/user-attachments/assets/32e6bf2e-610f-43b0-aa8c-72aa1ff62039" />

---

### SOAL 20: Audit Benchmark Menggunakan Apache Benchmark dari `kusakabe`
Menjalankan audit kapasitas beban menggunakan parameter `-n 600 -c 30` ke root web dan endpoint `/api`, membandingkan hasil baseline vs rate limiting, dan menganalisis access log `gojo`.

#### Node: kusakabe (Audit Terminal)
```bash
# 1. Benchmark Root Web (http://jujutsu.k16.com/)
ab -n 600 -c 30 http://jujutsu.k16.com/
```
* **Hasil Pengujian Web Baseline:**
  * **Concurrency Level:** `30`
  * **Complete Requests:** `600`
  * **Failed Requests:** `0`
  * **Requests per Second (RPS):** `6432.87 [#/sec]`
  * **Time per Request (Latensi):** `4.664 ms`

```bash
# 2. Benchmark API (/api) dengan Rate Limiting Aktif
ab -n 600 -c 30 http://jujutsu.k16.com/api
```
* **Hasil Pengujian API Rate Limiting:**
  * **Complete Requests:** `600`
  * **Failed Requests:** `599` (Non-2xx status: 598) akibat penolakan kebijakan rate limit 10 r/s.

#### Node: gojo (Pemeriksaan Log)
```bash
tail -n 15 /var/log/nginx/access.log
```
* **Cuplikan Access Log Gojo:**
  ```log
  192.219.3.2 - - [13/Oct/2026:15:41:26 +0000] "GET /api HTTP/1.0" 503 190 "-" "ApacheBench/2.3"
  192.219.3.2 - - [13/Oct/2026:15:41:26 +0000] "GET /api HTTP/1.0" 503 190 "-" "ApacheBench/2.3"
  192.219.3.2 - - [13/Oct/2026:15:41:26 +0000] "GET /api HTTP/1.0" 200 63 "-" "ApacheBench/2.3"
  ```

* **Tangkapan Layar Bukti Audit Benchmark & Log:**
![Bukti Pengujian Soal 20](images/soal20_benchmark_audit.png)
<img width="1024" height="665" alt="image" src="https://github.com/user-attachments/assets/d95c6aa6-0906-4b33-ba8c-5cd67f82565e" />
