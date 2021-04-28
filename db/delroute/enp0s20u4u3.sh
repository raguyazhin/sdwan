#!/bin/bash
ip route delete 192.168.42.0/24 dev enp0s20u4u3 src 192.168.42.208 table 1
ip route delete default via 192.168.42.129 table 1
ip rule del from all fwmark 0x1 lookup 1 2>/dev/null
ip rule del from all fwmark 0x1 2>/dev/null
ip rule del from 192.168.42.208
ip rule delete from 192.168.42.208 table 1
ip rule delete fwmark 1 table 1
iptables -t mangle -D MARK1 -j MARK --set-mark 1
iptables -t mangle -D MARK1 -j CONNMARK --save-mark
iptables -t mangle -F MARK1
iptables -t nat -D OUT_IF1 -j SNAT --to-source 192.168.42.208
iptables -t nat -F OUT_IF1
iptables -t nat -D POSTROUTING -o enp0s20u4u3 -j OUT_IF1
iptables -t nat -D IN_IF1 -j MARK --set-mark 1
iptables -t nat -D IN_IF1 -j CONNMARK --save-mark
iptables -t nat -F IN_IF1
iptables -t nat -D PREROUTING -i enp0s20u4u3 -j IN_IF1
iptables -t mangle -D PREROUTING -i enp1s0 -p tcp -m tcp -m state --state NEW -m statistic --mode random --probability 0.100 -j MARK1
iptables -t mangle -D PREROUTING -i enp1s0 -p tcp -m tcp -m state --state ESTABLISHED,RELATED -j CONNMARK --restore-mark
iptables -t mangle -D PREROUTING -i enp1s0 -p udp -m udp -m statistic --mode random --probability 0.100 -j MARK1
iptables -t mangle -D PREROUTING -p tcp --dport 53 -d 8.8.8.8 -j MARK1
iptables -t mangle -D PREROUTING -p udp --dport 53 -d 8.8.8.8 -j MARK1
