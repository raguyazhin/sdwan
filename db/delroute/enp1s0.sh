#!/bin/bash
ip route delete 103.60.139.0/27 dev enp1s0 src 103.60.139.21 table 212
ip route delete default via 103.60.139.1 table 212
ip rule del from all fwmark 0x212 lookup 212 2>/dev/null
ip rule del from all fwmark 0x212 2>/dev/null
ip rule del from 103.60.139.21
ip rule delete from 103.60.139.21 table 212
ip rule delete fwmark 212 table 212
iptables -t mangle -D MARK212 -j MARK --set-mark 212
iptables -t mangle -D MARK212 -j CONNMARK --save-mark
iptables -t nat -D ENP1S0_OUT_IF -j SNAT --to-source 103.60.139.21
iptables -t nat -D POSTROUTING -o enp1s0 -j ENP1S0_OUT_IF
iptables -t nat -D ENP1S0_IN_IF -j MARK --set-mark 212
iptables -t nat -D ENP1S0_IN_IF -j CONNMARK --save-mark
iptables -t nat -D PREROUTING -i enp1s0 -j ENP1S0_IN_IF
iptables -t mangle -D PREROUTING -i enp2s0 -p tcp -m tcp -m state --state ESTABLISHED,RELATED -j CONNMARK --restore-mark
iptables -t mangle -D PREROUTING -p tcp --dport 53 -d 172.20.10.52 -j MARK212
iptables -t mangle -D PREROUTING -p udp --dport 53 -d 172.20.10.52 -j MARK212
iptables -t mangle -X MARK212
iptables -t nat -X ENP1S0_OUT_IF
iptables -t nat -X ENP1S0_IN_IF
