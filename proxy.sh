#!/bin/sh


TPROXY_PORT=9001  
PROXY_MARK=1    
OUTPUT_MARK=255 

RULE_COUNTER=""
# RULE_COUNTER="counter"


cleanup() {
    nft flush ruleset >/dev/null 2>&1
    ip route del local default table 100 >/dev/null 2>&1
    ip rule del fwmark $PROXY_MARK table 100 >/dev/null 2>&1
}


setup() {
    ip rule add fwmark $PROXY_MARK table 100
    ip route add local default dev lo table 100
    nft -f - <<EOF
table ip sing-box-v4 {
   
    set RESERVED_IPSET {
        type ipv4_addr
        flags interval
        auto-merge 
        elements = {
            0.0.0.0/8,          
            10.0.0.0/8,         
            100.64.0.0/10,      
            127.0.0.0/8,       
            169.254.0.0/16,    
            172.16.0.0/12,     
            192.0.0.0/24,      
            192.0.2.0/24,       
            198.18.0.0/15,     
            198.51.100.0/24,   
            192.88.99.0/24,    
            192.168.0.0/16,     
            203.0.113.0/24,     
            224.0.0.0/4,       
            240.0.0.0/4,        
            255.255.255.255/32  
        }
    }

    
    chain prerouting {
        type filter hook prerouting priority mangle; policy accept;
        ct direction reply $RULE_COUNTER accept comment "Optimize: Reply Packets"
        ip protocol tcp socket transparent 1 $RULE_COUNTER meta mark set $PROXY_MARK accept comment "Optimize: Just re-route established TCP proxy connections"
        ip daddr @RESERVED_IPSET $RULE_COUNTER accept comment "Bypass: Reserved Address"
        ip protocol { tcp, udp } $RULE_COUNTER tproxy to 127.0.0.1:$TPROXY_PORT meta mark set $PROXY_MARK accept comment "Proxy: Default"
    }


    chain output {
        type route hook output priority mangle; policy accept;

        
        ct direction reply $RULE_COUNTER accept comment "Optimize: Reply Packets"

       
        meta mark $OUTPUT_MARK $RULE_COUNTER accept comment "Bypass: Proxy Output"

      


        ip daddr @RESERVED_IPSET $RULE_COUNTER accept comment "Bypass: Reserved Address"

        ip protocol { tcp, udp } $RULE_COUNTER meta mark set $PROXY_MARK accept comment "Re-route: Default Output"
    }
}
EOF
}

cleanup
if [ "$1" = "down" ]; then
    exit 0
fi
setup
