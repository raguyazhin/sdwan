rules=3
for ((j = rules ; j >= 1 ; j--)); do
  calc() { bc -l <<< "scale=3; $@"; }
  for ((i = rules ; i >= 1 ; i--)); do
    echo "/sbin/iptables -t nat -A REDSOCKS -p tcp -m statistic --mode random --probability $(calc 1/$i) -j REDIRECT --to-ports $(calc 10001+$rules-$i)"
  done
done


