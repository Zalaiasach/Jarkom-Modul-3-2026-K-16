#!/bin/bash
tcpdump -i eth0 -vvv -en -s 0 'port 67 or port 68'

