#!/bin/bash

source /root/sdwan/path.sh

# - n) LOGFILENAME 

while getopts l: option 
do 
    case "${option}" 
    in 
        l) LOGFILENAME=${OPTARG};; 
    esac 
done 

if [ -z $LOGFILENAME ]; then
    echo "provide -n LOG FILE NAME"
    exit 1
fi

tac ${LOGPATH}/${LOGFILENAME} > ${LOGPATH}/${LOGFILENAME}.tmp

while read line; do 
    substr=$substr'<tr><td>'${line}'</td></tr>'
done < ${LOGPATH}/${LOGFILENAME}.tmp

rm ${LOGPATH}/${LOGFILENAME}.tmp

echo "<table class='table'>
<thead>
<th scope='col'>Logs</th>
</thead>
$substr
</table>"