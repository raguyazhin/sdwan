#!/bin/bash

source /root/sdwan/path.sh

for intf in ${USRCONFPATH}/* ${PHYINTFPATH}/*; do

    if [ -f "${intf}" ]; then

        traffic=$(ifstat -i ${intf##*/} -q 1 1 | tail -1 | awk '{$1=$1};1')

        #echo $(echo $traffic | cut -d" " -f1)

        substr=$substr'<tr><td>'${intf##*/}'</td><td>'$(echo $traffic | cut -d" " -f1)'</td><td>'$(echo $traffic | cut -d" " -f2)'</td></tr>'
	
    fi

done

echo "<table class='table'>
<thead><th scope='col'>Interface</th>
<th scope='col'>In (KB/s)</th>
<th scope='col'>Out (KB/s)</th>
</thead>
$substr
</table>"