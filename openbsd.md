#setup ipv6 in openbsd 


/etc/rc.local

#!/bin/sh

sleep 6 # Adjust the delay if needed

ifconfig gif0 tunnel <your public ipv4> 45.32.66.87
ifconfig gif0 inet6 alias <your_pub_ipv6>::2/64
ifconfig gif0 up
route -n add -inet6 default <your_pub_ipv6>::1

exit 0


/etc/hostname.gif0                         
up


#setup pppoe on openbsd
/etc/hostname.pppoe0

inet 0.0.0.0 255.255.255.255 NONE mtu 1492 pppoedev em1 authproto pap authname 'pppoe_account' authkey 'pppoe_pass' up
dest 0.0.0.1
!/sbin/route add default -ifp pppoe0 0.0.0.
