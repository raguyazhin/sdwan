#!/bin/bash

source /root/sdwan/path.sh

while read i; do

  substr=$substr'<tr><td>'$(echo ${i} | cut -d',' -f1)'</td><td>'$(echo ${i} | cut -d',' -f3)'</td><td><img width="8" height="8" src="APP_BASE_URL/assets/img/'$(echo ${i} | cut -d',' -f2)'.png" alt=""></td></tr>'

done <${DBPATH}/intfs_status

echo "<table class='table'>
<thead><th scope='col'>Interface</th>
<th scope='col'>IP Address</th>
<th scope='col'>Status</th>
</thead>
$substr
</table>"