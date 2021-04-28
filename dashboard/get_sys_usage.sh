#! /bin/bash

cpu=$(top -bn1 | grep load | awk '{printf "%.2f%%", $(NF-2)}')
memory=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
disk=$(df -h | awk '$NF=="/"{printf "%s", $5}')

echo "$cpu,$memory,$disk"


