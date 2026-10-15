#!/bin/bash
pkill -9 dhcrelay 2>/dev/null
dhcrelay -i eth2 -i eth3 -i eth4 192.219.4.10

echo "DHCP Relay aktif menuju 192.219.4.10."

