#!/bin/sh

ITCMD="iptables"
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

# ALLOW INCOMING ICMP ERROR REPLY PACKETS TO COME IN
$ITCMD -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
$ITCMD -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
$ITCMD -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT

# ALLOW INCOMING ICMP ECHO PACKETS TO COME IN (RATE LIMITED)
$ITCMD -A INPUT -p icmp --icmp-type echo-request -m limit --limit 900/min -j ACCEPT
$ITCMD -A INPUT -p icmp --icmp-type echo-reply -m limit --limit 900/min -j ACCEPT

# PASS REMAINING PACKETS THROUGH CUSTOM CHAINS
$ITCMD -A INPUT -p tcp -j TCP
$ITCMD -A INPUT -p udp -j UDP

# PREVENT SYN-FLOOD (DROP EVERY NEW PACKET WHICH IS NOT A SYN)
$ITCMD -A TCP -p tcp ! --syn -m conntrack --ctstate NEW -j REJECT --reject-with tcp-reset

# ALLOW INCOMING TCP ON 80 (HTTP)
$ITCMD -A TCP -p tcp -m tcp --dport 80 -j ACCEPT

# ALLOW INCOMING TCP ON 443 (HTTPS)
$ITCMD -A TCP -p tcp -m tcp --dport 443 -j ACCEPT

# REJECT EVERYTHING ELSE (TCP)
$ITCMD -A TCP -p tcp -j REJECT --reject-with tcp-reset

# REJECT EVERYTHING ELSE (UDP)
$ITCMD -A UDP -p udp -j REJECT --reject-with icmp-port-unreachable

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
$ITCMD -t mangle -A SSLH --j MARK --set-mark 0x1
$ITCMD -t mangle -A SSLH --j ACCEPT
