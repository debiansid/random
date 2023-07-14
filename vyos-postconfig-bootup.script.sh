#!/bin/sh
# This script is executed at boot time after VyOS configuration is fully applied.
# Any modifications required to work around unfixed bugs
# or use services not available through the VyOS CLI system can be placed here.

#
/usr/sbin/modprobe ip_tables
/usr/sbin/modprobe ip_conntrack
/usr/sbin/modprobe iptable_filter
/usr/sbin/modprobe iptable_mangle
/usr/sbin/modprobe iptable_nat
/usr/sbin/modprobe ipt_LOG
/usr/sbin/modprobe ipt_limit
/usr/sbin/modprobe ipt_state

#setup unbound
useradd -d/etc/unbound -s/usr/sbin/nologin unbound
#systemctl start unbound

#start sing-box as user box
useradd -d/etc/sing-box -s/usr/sbin/nologin box
#sudo -u box /usr/bin/sing-box -D /var/lib/sing-box -c /etc/sing-box/tp.json run &

ip rule add fwmark 222 table 222 pref 222
ip route add local default dev lo table 222


iptables-legacy -t mangle -N BOX_EXTERNAL
iptables-legacy -t mangle -F BOX_EXTERNAL
iptables-legacy -t mangle -A BOX_EXTERNAL -d 192.168.88.0/24 -j RETURN
iptables-legacy -t mangle -A BOX_EXTERNAL -d 192.168.1.0/24 -j RETURN
iptables-legacy -t mangle -A BOX_EXTERNAL -d 0.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX_EXTERNAL -d 127.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX_EXTERNAL -d 10.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX_EXTERNAL -d 172.16.0.0/12 -j RETURN
iptables-legacy -t mangle -A BOX_EXTERNAL -d 192.168.0.0/16 -j RETURN
iptables-legacy -t mangle -A BOX_EXTERNAL -d 169.254.0.0/16 -j RETURN
iptables-legacy -t mangle -A BOX_EXTERNAL -d 224.0.0.0/4 -j RETURN
iptables-legacy -t mangle -A BOX_EXTERNAL -d 240.0.0.0/4 -j RETURN
#iptables-legacy -t mangle -A BOX_EXTERNAL ! -s 192.168.88.0/24 -j RETURN
iptables-legacy -t mangle -A BOX_EXTERNAL -p tcp -i lo -j TPROXY --on-ip 127.0.0.1 --on-port 1536 --tproxy-mark 222
iptables-legacy -t mangle -A BOX_EXTERNAL -p udp -i lo -j TPROXY --on-ip 127.0.0.1 --on-port 1536 --tproxy-mark 222
iptables-legacy -t mangle -A BOX_EXTERNAL -p tcp -i eth0 -j TPROXY --on-ip 127.0.0.1 --on-port 1536 --tproxy-mark 222
iptables-legacy -t mangle -A BOX_EXTERNAL -p udp -i eth0 -j TPROXY --on-ip 127.0.0.1 --on-port 1536 --tproxy-mark 222
iptables-legacy -t mangle -I PREROUTING -j BOX_EXTERNAL


iptables-legacy -t mangle -N BOX_LOCAL
iptables-legacy -t mangle -F BOX_LOCAL
iptables-legacy -t mangle -A BOX_LOCAL -d 192.168.88.0/24 -j RETURN
iptables-legacy -t mangle -A BOX_LOCAL -d 192.168.1.0/24 -j RETURN
iptables-legacy -t mangle -A BOX_LOCAL -d 0.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX_LOCAL -d 127.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX_LOCAL -d 10.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX_LOCAL -d 172.16.0.0/12 -j RETURN
iptables-legacy -t mangle -A BOX_LOCAL -d 192.168.0.0/16 -j RETURN
iptables-legacy -t mangle -A BOX_LOCAL -d 169.254.0.0/16 -j RETURN
iptables-legacy -t mangle -A BOX_LOCAL -d 224.0.0.0/4 -j RETURN
iptables-legacy -t mangle -A BOX_LOCAL -d 240.0.0.0/4 -j RETURN
iptables-legacy -t mangle -I BOX_LOCAL -m owner --uid-owner box --gid-owner box -j RETURN
iptables-legacy -t mangle -A BOX_LOCAL -p tcp -j MARK --set-mark 222
iptables-legacy -t mangle -A BOX_LOCAL -p udp -j MARK --set-mark 222
iptables-legacy -t mangle -I OUTPUT -j BOX_LOCAL

iptables-legacy  -t mangle -N DIVERT
iptables-legacy  -t mangle -F DIVERT
iptables-legacy  -t mangle -A DIVERT -j MARK --set-mark 222
iptables-legacy  -t mangle -A DIVERT -j ACCEPT
iptables-legacy  -t mangle -I PREROUTING -p tcp -m socket -j DIVERT

iptables-legacy  -A OUTPUT -d 127.0.0.1 -p tcp -m owner --uid-owner box --gid-owner box -m tcp --dport 1536 -j REJECT
##############################################
# FULLCONENAT Rules
iptables-legacy -t nat -I POSTROUTING -o pppoe0 -j FULLCONENAT
iptables-legacy -t nat -I PREROUTING -i pppoe0 -j FULLCONENAT
iptables-legacy -t nat -I PREROUTING -i eth0 -j FULLCONENAT
#iptables-legacy -t nat -I PREROUTING -i eth2 -j FULLCONENAT
#iptables-legacy -t nat -I PREROUTING -i wg0 -j FULLCONENAT
