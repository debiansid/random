setup ipv6 in openbsd 


/etc/rc.local

#!/bin/sh

sleep 6 # Adjust the delay if needed

ifconfig gif0 tunnel your public ipv4 45.32.66.87
ifconfig gif0 inet6 alias your_pub_ipv6::2/64
ifconfig gif0 up
route -n add -inet6 default your_pub_ipv6::1

exit 0


/etc/hostname.gif0                         
up
