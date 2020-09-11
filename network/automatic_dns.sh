#!/bin/bash
# Set automati DNS using resolv.conf for Debian derivations
# Rev 1.0 2020-09-09, jgmm81@gmail.com
# Tested on: Ubuntu 20.04LTS, 

# More Info
# https://www.lifewire.com/free-and-public-dns-servers-2626062
# https://www.ricmedia.com/set-permanent-dns-nameservers-ubuntu-debian-resolv-conf/

RESOLV_HEAD_FILE="/etc/resolvconf/resolv.conf.d/head"

apt-get install -y resolvconf sed

systemctl enable resolvconf.service
systemctl start resolvconf.service

DNS_SERVERS=(
    'nameserver 8.8.8.8'
    'nameserver 8.8.4.4'
    'nameserver 1.1.1.1'
    'nameserver 1.0.0.1'
    'nameserver 208.67.222.222'
    'nameserver 208.67.220.220'
)

for index in ${!DNS_SERVERS[@]}; do
   if [ $index -gt -1 ]; then
       grep -qxF "${DNS_SERVERS[$index]}" ${RESOLV_HEAD_FILE} || echo "${DNS_SERVERS[$index]}" >> ${RESOLV_HEAD_FILE}
   fi
done

resolvconf --enable-updates
resolvconf -u

#systemd-resolve --status | grep 'DNS Servers' -A2
#systemctl status resolvconf.service

systemd-resolve --status
