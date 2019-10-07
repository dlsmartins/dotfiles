#!/bin/sh

ITCMD="ip6tables"
IFPUB="eth0"
IFLO="lo"

# CLEAN EVERYTHING
$ITCMD -F
$ITCMD -X

# CREATE NEW CUSTOM CHAINS
$ITCMD -N TCP
$ITCMD -N UDP

# ALLOW ANYTHING ON THE LOCAL LINK
$ITCMD -A INPUT -i $IFLO -j ACCEPT
$ITCMD -A OUTPUT -o $IFLO -j ACCEPT

# ALLOW EVERYTHING TO GO OUT ON THE INTERNET
$ITCMD -A OUTPUT -o $IFPUB -j ACCEPT

# ALLOW ESTABLISHED, RELATED PACKETS BACK IN
$ITCMD -A INPUT -i $IFPUB -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# DROP INVALID PACKETS
$ITCMD -A INPUT -m conntrack --ctstate INVALID -j DROP

# ALLOW INCOMING ICMPV6 ERROR REPLY PACKETS TO COME IN
$ITCMD -A INPUT -p icmpv6 --icmpv6-type destination-unreachable -j ACCEPT
$ITCMD -A INPUT -p icmpv6 --icmpv6-type packet-too-big -j ACCEPT
$ITCMD -A INPUT -p icmpv6 --icmpv6-type time-exceeded -j ACCEPT
$ITCMD -A INPUT -p icmpv6 --icmpv6-type parameter-problem -j ACCEPT

# ALLOW INCOMING ICMPV6 ECHO PACKETS TO COME IN (RATE LIMITED)
$ITCMD -A INPUT -p icmpv6 --icmpv6-type echo-request -m limit --limit 900/min -j ACCEPT
$ITCMD -A INPUT -p icmpv6 --icmpv6-type echo-reply -m limit --limit 900/min -j ACCEPT

# ALLOW OTHER ICMPV6 PACKET TYPES (IF HOP-LIMIT IS 255)
$ITCMD -A INPUT -p icmpv6 --icmpv6-type router-advertisement -m hl --hl-eq 255 -j ACCEPT
$ITCMD -A INPUT -p icmpv6 --icmpv6-type neighbor-solicitation -m hl --hl-eq 255 -j ACCEPT
$ITCMD -A INPUT -p icmpv6 --icmpv6-type neighbor-advertisement -m hl --hl-eq 255 -j ACCEPT
$ITCMD -A INPUT -p icmpv6 --icmpv6-type redirect -m hl --hl-eq 255 -j ACCEPT

# DROP PACKETS WITH RH0 HEADERS
$ITCMD -A INPUT -m rt --rt-type 0 -j DROP
$ITCMD -A FORWARD -m rt --rt-type 0 -j DROP
$ITCMD -A OUTPUT -m rt --rt-type 0 -j DROP

# ALLOW LINK-LOCAL ADDRESSES
$ITCMD -A INPUT -s fe80::/10 -j ACCEPT
$ITCMD -A OUTPUT -s fe80::/10 -j ACCEPT

# ALLOW MULTICAST
$ITCMD -A INPUT -d ff00::/8 -j ACCEPT
$ITCMD -A OUTPUT -d ff00::/8 -j ACCEPT

# PASS REMAINING PACKETS THROUGH CUSTOM CHAINS
$ITCMD -A INPUT -p tcp -j TCP
$ITCMD -A INPUT -p udp -j UDP

# PREVENT SYN-FLOOD (DROP EVERY NEW PACKET WHICH IS NOT A SYN)
$ITCMD -A TCP -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

# ALLOW INCOMING TCP ON 80 (HTTP)
$ITCMD -A TCP -p tcp -m tcp --dport 80 -j ACCEPT

# ALLOW INCOMING TCP ON 443 (HTTPS)
$ITCMD -A TCP -p tcp -m tcp --dport 443 -j ACCEPT

# REJECT EVERYTHING ELSE (TCP)
$ITCMD -A TCP -p tcp -j REJECT --reject-with tcp-reset

# REJECT EVERYTHING ELSE (UDP)
$ITCMD -A UDP -p udp -j REJECT --reject-with icmp6-port-unreachable

# SET DEFAULT POLICIES TO DROP
$ITCMD -P INPUT DROP
$ITCMD -P FORWARD DROP
$ITCMD -P OUTPUT DROP

# SSLH
$ITCMD -t mangle -F
$ITCMD -t mangle -X
$ITCMD -t mangle -N SSLH
$ITCMD -t mangle -A OUTPUT -p tcp --out-interface $IFPUB --sport 22 -j SSLH
$ITCMD -t mangle -A OUTPUT -p tcp --out-interface $IFPUB --sport 4443 -j SSLH
$ITCMD -t mangle -A SSLH -j MARK --set-mark 0x1
$ITCMD -t mangle -A SSLH -j ACCEPT
