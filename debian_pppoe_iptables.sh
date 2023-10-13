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

ip rule add fwmark 0x1 lookup 100
ip route add local default dev lo table 100


iptables-legacy -t mangle -N BOX

iptables-legacy -t mangle -A BOX -p tcp -m socket --transparent -j MARK --set-mark 0x1
iptables-legacy -t mangle -A BOX -p udp -m socket --transparent -j MARK --set-mark 0x1
iptables-legacy -t mangle -A BOX -m socket -j RETURN


iptables-legacy -t mangle -A BOX -d 0.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX -d 10.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX -d 127.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX -d 169.254.0.0/16 -j RETURN
iptables-legacy -t mangle -A BOX -d 172.16.0.0/12 -j RETURN
iptables-legacy -t mangle -A BOX -d 192.168.0.0/16 -j RETURN
iptables-legacy -t mangle -A BOX -d 224.0.0.0/4 -j RETURN
iptables-legacy -t mangle -A BOX -d 240.0.0.0/4 -j RETURN

iptables-legacy -t mangle -A BOX ! -s 192.168.88.0/24 -j RETURN
iptables-legacy -t mangle -A BOX -p tcp -j TPROXY --on-port 1536 --on-ip 127.0.0.1 --tproxy-mark 0x1
iptables-legacy -t mangle -A BOX -p udp -j TPROXY --on-port 1536 --on-ip 127.0.0.1 --tproxy-mark 0x1


iptables-legacy -t mangle -A PREROUTING -j BOX



iptables-legacy -t mangle -N BOX_MARK


iptables-legacy -t mangle -A BOX_MARK -m owner --uid-owner box -j RETURN


iptables-legacy -t mangle -A BOX_MARK -d 0.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX_MARK -d 10.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX_MARK -d 127.0.0.0/8 -j RETURN
iptables-legacy -t mangle -A BOX_MARK -d 169.254.0.0/16 -j RETURN
iptables-legacy -t mangle -A BOX_MARK -d 172.16.0.0/12 -j RETURN
iptables-legacy -t mangle -A BOX_MARK -d 192.168.0.0/16 -j RETURN
iptables-legacy -t mangle -A BOX_MARK -d 224.0.0.0/4 -j RETURN
iptables-legacy -t mangle -A BOX_MARK -d 240.0.0.0/4 -j RETURN


iptables-legacy -t mangle -A BOX_MARK -p tcp -j MARK --set-mark 0x1
iptables-legacy -t mangle -A BOX_MARK -p udp -j MARK --set-mark 0x1


iptables-legacy -t mangle -A OUTPUT -j BOX_MARK





##############################################
# FULLCONENAT Rules
iptables-legacy -t nat -I POSTROUTING -o ppp0 -j FULLCONENAT
iptables-legacy -t nat -I PREROUTING -i ppp0 -j FULLCONENAT
iptables-legacy -t nat -I PREROUTING -i ens192 -j FULLCONENAT
#iptables-legacy -t nat -I PREROUTING -i eth2 -j FULLCONENAT
#iptables-legacy -t nat -I PREROUTING -i wg0 -j FULLCONENAT
