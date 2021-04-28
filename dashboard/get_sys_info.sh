#!/bin/bash

name=$(uname -n)
version=$(uname -mrs)
cpu_type=$(lscpu | grep "Model name" | cut -d ":" -f2)
# uptime=$(uptime | cut -d "," -f1)
uptime=$(uptime -p | cut -d " " -f2-)
date_time=$(date +"%A, %b %d, %Y %I:%M:%S %p")

memory=$(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }' | cut -d ":" -f2)
disk=$(df -h | awk '$NF=="/"{printf "Disk Usage: %d/%dGB (%s)\n", $3,$2,$5}' | cut -d ":" -f2)
cpu=$(top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}' | cut -d ":" -f2) 

echo "<table class='table'>
<tr><td>Name</td><td style='font-weight: bold'>$name</td></tr>
<tr><td>Version</td><td style='font-weight: bold'>$version</td></tr>
<tr><td>CPU Type</td><td style='font-weight: bold'>$cpu_type</td></tr>
<tr><td>Uptime</td><td style='font-weight: bold'>$uptime</td></tr>
<tr><td>Current date/time</td><td style='font-weight: bold'>$date_time</td></tr>
<tr><td>CPU</td><td style='font-weight: bold'>$cpu<span>&#37;</span></td></tr>
<tr><td>Memory</td><td style='font-weight: bold'>$memory</td></tr>
<tr><td>Disk</td><td style='font-weight: bold'>$disk</td></tr>
</table>"

# echo $name
# echo $version
# echo $cpu_type
# echo $uptime
# echo $date_time

# echo $memory
# echo $disk
# echo $cpu