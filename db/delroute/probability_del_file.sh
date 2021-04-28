iptables -t mangle -D PREROUTING -i enp2s0 -p tcp -m tcp -m state --state NEW -m statistic --mode nth --every 2 --packet 0 -j MARK212
iptables -t mangle -D PREROUTING -i enp2s0 -p udp -m udp -m state --state NEW -m statistic --mode nth --every 2 --packet 0 -j MARK212
iptables -t mangle -D PREROUTING -i enp2s0 -p tcp -m tcp -m state --state NEW -m statistic --mode nth --every 2 --packet 1 -j MARK134
iptables -t mangle -D PREROUTING -i enp2s0 -p udp -m udp -m state --state NEW -m statistic --mode nth --every 2 --packet 1 -j MARK134
